import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_file_store_web.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_pick_memory.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_proof_state.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_error_keys.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_result.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/hive_test_helpers.dart' as test_helpers;

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStaffDemoEventProofRepository extends Mock
    implements StaffDemoEventProofRepository {}

class _MockStaffDemoProofFileStore extends Mock
    implements StaffDemoProofFileStore {}

class _MockStaffDemoProofPhotoPicker extends Mock
    implements StaffDemoProofPhotoPicker {}

Future<void> _pumpUntil(
  bool Function() predicate, {
  Duration step = const Duration(milliseconds: 10),
  int maxAttempts = 100,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(step);
  }
  fail('Condition not met within ${step * maxAttempts}');
}

void _stubProofFileStore(_MockStaffDemoProofFileStore fileStore) {
  when(() => fileStore.fileExists(any())).thenAnswer((
    final Invocation inv,
  ) async {
    final path = inv.positionalArguments[0] as String;
    return File(path).exists();
  });
  when(() => fileStore.deleteFileAtPath(any())).thenAnswer((_) async {});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StaffDemoProofCubit', () {
    test(
      'ignores duplicate submits while a proof upload is already in flight',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final fileStore = _MockStaffDemoProofFileStore();
        final completer = Completer<String>();
        final tempDir = await Directory.systemTemp.createTemp(
          'staff-proof-test',
        );
        final signatureFile = File('${tempDir.path}/signature.png');
        await signatureFile.writeAsBytes(const <int>[1, 2, 3], flush: true);

        when(() => authRepository.currentUser).thenReturn(
          const AuthUser(
            id: 'u1',
            email: 'user@example.com',
            isAnonymous: false,
          ),
        );
        when(
          () => repository.submitProof(
            userId: any(named: 'userId'),
            siteId: any(named: 'siteId'),
            shiftId: any(named: 'shiftId'),
            photoFilePaths: any(named: 'photoFilePaths'),
            signaturePngFilePath: any(named: 'signaturePngFilePath'),
          ),
        ).thenAnswer((_) => completer.future);
        _stubProofFileStore(fileStore);

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: _MockStaffDemoProofPhotoPicker(),
        );
        addTearDown(() async {
          await cubit.close();
          await tempDir.delete(recursive: true);
        });

        cubit.setSignaturePath(signatureFile.path);

        final first = cubit.submit(siteId: 'site1', shiftId: null);
        await _pumpUntil(
          () => cubit.state.status == StaffDemoProofStatus.submitting,
        );

        unawaited(cubit.submit(siteId: 'site1', shiftId: null));

        verify(
          () => repository.submitProof(
            userId: 'u1',
            siteId: 'site1',
            shiftId: null,
            photoFilePaths: const <String>[],
            signaturePngFilePath: signatureFile.path,
          ),
        ).called(1);

        completer.complete('proof-1');
        await first;
      },
    );

    test(
      'marks the proof flow offline queued when the repository enqueues work',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final fileStore = _MockStaffDemoProofFileStore();
        final tempDir = await Directory.systemTemp.createTemp(
          'staff-proof-offline-test',
        );
        final signatureFile = File('${tempDir.path}/signature.png');
        await signatureFile.writeAsBytes(const <int>[1, 2, 3], flush: true);

        when(() => authRepository.currentUser).thenReturn(
          const AuthUser(
            id: 'u1',
            email: 'user@example.com',
            isAnonymous: false,
          ),
        );
        when(
          () => repository.submitProof(
            userId: any(named: 'userId'),
            siteId: any(named: 'siteId'),
            shiftId: any(named: 'shiftId'),
            photoFilePaths: any(named: 'photoFilePaths'),
            signaturePngFilePath: any(named: 'signaturePngFilePath'),
          ),
        ).thenThrow(const StaffDemoEventProofOfflineEnqueuedException());
        _stubProofFileStore(fileStore);

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: _MockStaffDemoProofPhotoPicker(),
        );
        addTearDown(() async {
          await cubit.close();
          await tempDir.delete(recursive: true);
        });

        cubit.setSignaturePath(signatureFile.path);
        await cubit.submit(siteId: 'site1', shiftId: null);

        expect(cubit.state.status, StaffDemoProofStatus.offlineQueued);
        expect(cubit.state.errorMessage, isNull);
        verify(
          () => repository.submitProof(
            userId: 'u1',
            siteId: 'site1',
            shiftId: null,
            photoFilePaths: const <String>[],
            signaturePngFilePath: signatureFile.path,
          ),
        ).called(1);
      },
    );

    test(
      'ignores second submit while first is validating local files',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final fileStore = _MockStaffDemoProofFileStore();
        final completer = Completer<String>();
        final tempDir = await Directory.systemTemp.createTemp(
          'staff-proof-validate-overlap-test',
        );
        final signatureFile = File('${tempDir.path}/signature.png');
        await signatureFile.writeAsBytes(const <int>[1, 2, 3], flush: true);

        when(() => authRepository.currentUser).thenReturn(
          const AuthUser(
            id: 'u1',
            email: 'user@example.com',
            isAnonymous: false,
          ),
        );
        when(
          () => repository.submitProof(
            userId: any(named: 'userId'),
            siteId: any(named: 'siteId'),
            shiftId: any(named: 'shiftId'),
            photoFilePaths: any(named: 'photoFilePaths'),
            signaturePngFilePath: any(named: 'signaturePngFilePath'),
          ),
        ).thenAnswer((_) => completer.future);
        _stubProofFileStore(fileStore);

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: _MockStaffDemoProofPhotoPicker(),
        );
        addTearDown(() async {
          await cubit.close();
          await tempDir.delete(recursive: true);
        });

        cubit.setSignaturePath(signatureFile.path);

        final first = cubit.submit(siteId: 'site1', shiftId: null);
        final second = cubit.submit(siteId: 'site1', shiftId: null);
        await Future<void>.delayed(Duration.zero);

        completer.complete('proof-1');
        await first;
        await second;

        verify(
          () => repository.submitProof(
            userId: 'u1',
            siteId: 'site1',
            shiftId: null,
            photoFilePaths: const <String>[],
            signaturePngFilePath: signatureFile.path,
          ),
        ).called(1);
      },
    );

    test('removePhotoAt deletes persisted file from store', () async {
      final authRepository = _MockAuthRepository();
      final repository = _MockStaffDemoEventProofRepository();
      final fileStore = _MockStaffDemoProofFileStore();
      _stubProofFileStore(fileStore);

      when(() => authRepository.currentUser).thenReturn(
        const AuthUser(id: 'u1', email: 'user@example.com', isAnonymous: false),
      );

      final cubit = StaffDemoProofCubit(
        authRepository: authRepository,
        repository: repository,
        fileStore: fileStore,
        photoPicker: _MockStaffDemoProofPhotoPicker(),
      );
      addTearDown(cubit.close);

      cubit.setPhotos(<String>['/tmp/photo-a.jpg', '/tmp/photo-b.jpg']);
      cubit.removePhotoAt(0);

      expect(cubit.state.photoPaths, <String>['/tmp/photo-b.jpg']);
      verify(() => fileStore.deleteFileAtPath('/tmp/photo-a.jpg')).called(1);
    });

    test('surfaces error when signature file is missing on disk', () async {
      final authRepository = _MockAuthRepository();
      final repository = _MockStaffDemoEventProofRepository();
      final fileStore = _MockStaffDemoProofFileStore();

      when(() => authRepository.currentUser).thenReturn(
        const AuthUser(id: 'u1', email: 'user@example.com', isAnonymous: false),
      );
      when(() => fileStore.fileExists(any())).thenAnswer((_) async => false);

      final cubit = StaffDemoProofCubit(
        authRepository: authRepository,
        repository: repository,
        fileStore: fileStore,
        photoPicker: _MockStaffDemoProofPhotoPicker(),
      );
      addTearDown(cubit.close);

      cubit.setSignaturePath('/tmp/staff-proof-missing-signature.png');
      await cubit.submit(siteId: 'site1', shiftId: null);

      expect(cubit.state.status, StaffDemoProofStatus.error);
      expect(cubit.state.errorMessage, 'Signature file missing.');
      verifyNever(
        () => repository.submitProof(
          userId: any(named: 'userId'),
          siteId: any(named: 'siteId'),
          shiftId: any(named: 'shiftId'),
          photoFilePaths: any(named: 'photoFilePaths'),
          signaturePngFilePath: any(named: 'signaturePngFilePath'),
        ),
      );
    });

    test('surfaces error when a photo file is missing on disk', () async {
      final authRepository = _MockAuthRepository();
      final repository = _MockStaffDemoEventProofRepository();
      final fileStore = _MockStaffDemoProofFileStore();
      final tempDir = await Directory.systemTemp.createTemp(
        'staff-proof-missing-photo-test',
      );
      final signatureFile = File('${tempDir.path}/signature.png');
      await signatureFile.writeAsBytes(const <int>[1, 2, 3], flush: true);

      when(() => authRepository.currentUser).thenReturn(
        const AuthUser(id: 'u1', email: 'user@example.com', isAnonymous: false),
      );
      when(() => fileStore.fileExists(any())).thenAnswer((
        final Invocation inv,
      ) async {
        final path = inv.positionalArguments[0] as String;
        if (path.endsWith('missing-photo.jpg')) {
          return false;
        }
        return File(path).exists();
      });

      final cubit = StaffDemoProofCubit(
        authRepository: authRepository,
        repository: repository,
        fileStore: fileStore,
        photoPicker: _MockStaffDemoProofPhotoPicker(),
      );
      addTearDown(() async {
        await cubit.close();
        await tempDir.delete(recursive: true);
      });

      cubit
        ..setSignaturePath(signatureFile.path)
        ..setPhotos(<String>['${tempDir.path}/missing-photo.jpg']);
      await cubit.submit(siteId: 'site1', shiftId: null);

      expect(cubit.state.status, StaffDemoProofStatus.error);
      expect(
        cubit.state.errorMessage,
        'A photo file is missing locally. Please re-add it.',
      );
      verifyNever(
        () => repository.submitProof(
          userId: any(named: 'userId'),
          siteId: any(named: 'siteId'),
          shiftId: any(named: 'shiftId'),
          photoFilePaths: any(named: 'photoFilePaths'),
          signaturePngFilePath: any(named: 'signaturePngFilePath'),
        ),
      );
    });

    test(
      'pickPhotoFromCamera persists photo and returns null on success',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final fileStore = _MockStaffDemoProofFileStore();
        final mockImagePicker = _MockImagePicker();
        final photoPicker = ImagePickerStaffDemoProofPhotoPicker(
          picker: mockImagePicker,
        );
        final tempDir = await Directory.systemTemp.createTemp(
          'staff-proof-pick-test',
        );
        final sourceFile = File('${tempDir.path}/source.jpg');
        await sourceFile.writeAsBytes(const <int>[1], flush: true);

        when(
          () => mockImagePicker.pickImage(source: ImageSource.camera),
        ).thenAnswer((_) async => _FakeXFile(sourceFile.path));
        when(
          () => fileStore.persistPhotoFile(sourcePath: sourceFile.path),
        ).thenAnswer((_) async => '${tempDir.path}/persisted.jpg');
        _stubProofFileStore(fileStore);

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: photoPicker,
        );
        addTearDown(() async {
          await cubit.close();
          await tempDir.delete(recursive: true);
        });

        final errorKey = await cubit.pickPhotoFromCamera();

        expect(errorKey, isNull);
        expect(cubit.state.photoPaths, <String>[
          '${tempDir.path}/persisted.jpg',
        ]);
      },
    );

    test(
      'pickPhotoFromCamera returns generic error when persist fails',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final fileStore = _MockStaffDemoProofFileStore();
        final mockImagePicker = _MockImagePicker();
        final photoPicker = ImagePickerStaffDemoProofPhotoPicker(
          picker: mockImagePicker,
        );
        final tempDir = await Directory.systemTemp.createTemp(
          'staff-proof-pick-fail-test',
        );
        final sourceFile = File('${tempDir.path}/source.jpg');
        await sourceFile.writeAsBytes(const <int>[1], flush: true);

        when(
          () => mockImagePicker.pickImage(source: ImageSource.camera),
        ).thenAnswer((_) async => _FakeXFile(sourceFile.path));
        when(
          () => fileStore.persistPhotoFile(sourcePath: sourceFile.path),
        ).thenThrow(Exception('disk full'));
        _stubProofFileStore(fileStore);

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: photoPicker,
        );
        addTearDown(() async {
          await cubit.close();
          await tempDir.delete(recursive: true);
        });

        final errorKey = await cubit.pickPhotoFromCamera();

        expect(errorKey, MediaPickErrorKeys.generic);
        expect(cubit.state.photoPaths, isEmpty);
      },
    );

    test('ignores second pick while first pick is still in flight', () async {
      final authRepository = _MockAuthRepository();
      final repository = _MockStaffDemoEventProofRepository();
      final fileStore = _MockStaffDemoProofFileStore();
      final photoPicker = _MockStaffDemoProofPhotoPicker();
      final completer = Completer<MediaPickResult>();
      final tempDir = await Directory.systemTemp.createTemp(
        'staff-proof-pick-overlap-test',
      );
      final sourceFile = File('${tempDir.path}/source.jpg');
      await sourceFile.writeAsBytes(const <int>[1], flush: true);

      when(
        () => photoPicker.pickFromCamera(),
      ).thenAnswer((_) => completer.future);
      when(
        () => fileStore.persistPhotoFile(sourcePath: sourceFile.path),
      ).thenAnswer((_) async => '${tempDir.path}/persisted.jpg');
      _stubProofFileStore(fileStore);

      final cubit = StaffDemoProofCubit(
        authRepository: authRepository,
        repository: repository,
        fileStore: fileStore,
        photoPicker: photoPicker,
      );
      addTearDown(() async {
        await cubit.close();
        await tempDir.delete(recursive: true);
      });

      final first = cubit.pickPhotoFromCamera();
      final second = cubit.pickPhotoFromGallery();
      await Future<void>.delayed(Duration.zero);

      completer.complete(MediaPickResult.success(sourceFile.path));
      await first;
      await second;

      verify(() => photoPicker.pickFromCamera()).called(1);
      verifyNever(() => photoPicker.pickFromGallery());
      expect(cubit.state.photoPaths, <String>['${tempDir.path}/persisted.jpg']);
    });

    test(
      'pickPhotoFromGallery returns error key on permission denial',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final fileStore = _MockStaffDemoProofFileStore();
        final mockImagePicker = _MockImagePicker();
        final photoPicker = ImagePickerStaffDemoProofPhotoPicker(
          picker: mockImagePicker,
        );

        when(
          () => mockImagePicker.pickImage(source: ImageSource.gallery),
        ).thenThrow(PlatformException(code: 'photo_access_denied'));
        _stubProofFileStore(fileStore);

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: photoPicker,
        );
        addTearDown(cubit.close);

        final errorKey = await cubit.pickPhotoFromGallery();

        expect(errorKey, MediaPickErrorKeys.permissionDenied);
        expect(cubit.state.photoPaths, isEmpty);
      },
    );
  });

  group('StaffDemoProofCubit web store', () {
    setUpAll(test_helpers.setupHiveForTesting);

    tearDown(() async {
      if (Hive.isBoxOpen(LocalStaffDemoProofFileStore.boxName)) {
        await Hive.box<dynamic>(LocalStaffDemoProofFileStore.boxName).close();
      }
      await Hive.deleteBoxFromDisk(LocalStaffDemoProofFileStore.boxName);
    });

    test(
      'pickPhotoFromGallery persists web data URL through local proof store',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final hiveService = HiveService(
          keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
          initializeHiveStorage: () async => true,
        );
        await hiveService.initialize();
        final fileStore = LocalStaffDemoProofFileStore(
          hiveService: hiveService,
        );
        final photoPicker = _MockStaffDemoProofPhotoPicker();
        const bytes = <int>[0xFF, 0xD8, 0xFF, 0x00];
        final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        when(
          () => photoPicker.pickFromGallery(),
        ).thenAnswer((_) async => MediaPickResult.success(dataUrl));

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: photoPicker,
        );
        addTearDown(cubit.close);

        final errorKey = await cubit.pickPhotoFromGallery();

        expect(errorKey, isNull);
        expect(cubit.state.photoPaths, hasLength(1));
        expect(
          await fileStore.readFileBytes(cubit.state.photoPaths.single),
          bytes,
        );
      },
    );

    test('releases staged web pick memory when persist fails', () async {
      final authRepository = _MockAuthRepository();
      final repository = _MockStaffDemoEventProofRepository();
      final fileStore = _MockStaffDemoProofFileStore();
      final photoPicker = _MockStaffDemoProofPhotoPicker();
      const bytes = <int>[0xFF, 0xD8, 0xFF, 0x00];
      final pickPath = StaffDemoProofPickMemory.instance.stage(bytes);

      when(
        () => photoPicker.pickFromGallery(),
      ).thenAnswer((_) async => MediaPickResult.success(pickPath));
      when(
        () => fileStore.persistPhotoFile(sourcePath: pickPath),
      ).thenThrow(Exception('disk full'));
      _stubProofFileStore(fileStore);

      final cubit = StaffDemoProofCubit(
        authRepository: authRepository,
        repository: repository,
        fileStore: fileStore,
        photoPicker: photoPicker,
      );
      addTearDown(cubit.close);

      final errorKey = await cubit.pickPhotoFromGallery();

      expect(errorKey, MediaPickErrorKeys.generic);
      expect(cubit.state.photoPaths, isEmpty);
      expect(StaffDemoProofPickMemory.instance.peek(pickPath), isNull);
    });

    test(
      'returns generic error when persist throws StateError from web store path',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final fileStore = _MockStaffDemoProofFileStore();
        final photoPicker = _MockStaffDemoProofPhotoPicker();
        const bytes = <int>[0xFF, 0xD8, 0xFF, 0x00];
        final pickPath = StaffDemoProofPickMemory.instance.stage(bytes);

        when(
          () => photoPicker.pickFromGallery(),
        ).thenAnswer((_) async => MediaPickResult.success(pickPath));
        when(
          () => fileStore.persistPhotoFile(sourcePath: pickPath),
        ).thenThrow(StateError('debug simulated put failure'));
        _stubProofFileStore(fileStore);

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: photoPicker,
        );
        addTearDown(cubit.close);

        final errorKey = await cubit.pickPhotoFromGallery();

        expect(errorKey, MediaPickErrorKeys.generic);
        expect(cubit.state.photoPaths, isEmpty);
        expect(StaffDemoProofPickMemory.instance.peek(pickPath), isNull);
      },
    );

    test(
      'releases staged web pick memory when cubit closes before persist',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final fileStore = _MockStaffDemoProofFileStore();
        final photoPicker = _MockStaffDemoProofPhotoPicker();
        const bytes = <int>[0xFF, 0xD8, 0xFF, 0x00];
        final pickPath = StaffDemoProofPickMemory.instance.stage(bytes);
        final persistGate = Completer<void>();

        when(
          () => photoPicker.pickFromGallery(),
        ).thenAnswer((_) async => MediaPickResult.success(pickPath));
        when(() => fileStore.persistPhotoFile(sourcePath: pickPath)).thenAnswer(
          (_) async {
            await persistGate.future;
            return '${Directory.systemTemp.path}/never.jpg';
          },
        );
        _stubProofFileStore(fileStore);

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: photoPicker,
        );

        final pickFuture = cubit.pickPhotoFromGallery();
        await Future<void>.delayed(Duration.zero);
        final closeFuture = cubit.close();
        persistGate.complete();
        await closeFuture;

        expect(await pickFuture, isNull);
        expect(StaffDemoProofPickMemory.instance.peek(pickPath), isNull);
      },
    );

    test(
      'awaits in-flight web persist before releasing staged bytes on close',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoEventProofRepository();
        final hiveService = HiveService(
          keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
          initializeHiveStorage: () async => true,
        );
        await hiveService.initialize();
        final innerStore = LocalStaffDemoProofFileStore(
          hiveService: hiveService,
        );
        final persistStarted = Completer<void>();
        final persistGate = Completer<void>();
        final fileStore = _GatingStaffDemoProofFileStore(
          delegate: innerStore,
          onPersistStart: persistStarted.complete,
          beforePersist: () => persistGate.future,
        );
        final photoPicker = _MockStaffDemoProofPhotoPicker();
        const bytes = <int>[0xFF, 0xD8, 0xFF, 0x00];
        final pickPath = StaffDemoProofPickMemory.instance.stage(bytes);

        when(
          () => photoPicker.pickFromGallery(),
        ).thenAnswer((_) async => MediaPickResult.success(pickPath));

        final cubit = StaffDemoProofCubit(
          authRepository: authRepository,
          repository: repository,
          fileStore: fileStore,
          photoPicker: photoPicker,
        );

        final pickFuture = cubit.pickPhotoFromGallery();
        await persistStarted.future;
        final closeFuture = cubit.close();
        persistGate.complete();
        await closeFuture;

        expect(await pickFuture, isNull);
        expect(StaffDemoProofPickMemory.instance.peek(pickPath), isNull);
        expect(cubit.state.photoPaths, isEmpty);
      },
    );
  });
}

class _GatingStaffDemoProofFileStore implements StaffDemoProofFileStore {
  _GatingStaffDemoProofFileStore({
    required this.delegate,
    required this.onPersistStart,
    required this.beforePersist,
  });

  final StaffDemoProofFileStore delegate;
  final void Function() onPersistStart;
  final Future<void> Function() beforePersist;

  @override
  Future<String> persistPhotoFile({required String sourcePath}) async {
    onPersistStart();
    await beforePersist();
    return delegate.persistPhotoFile(sourcePath: sourcePath);
  }

  @override
  Future<String> persistSignaturePngBytes({required List<int> bytes}) =>
      delegate.persistSignaturePngBytes(bytes: bytes);

  @override
  Future<bool> fileExists(String path) => delegate.fileExists(path);

  @override
  Future<List<int>> readFileBytes(String path) => delegate.readFileBytes(path);

  @override
  Future<void> deleteFileAtPath(String path) => delegate.deleteFileAtPath(path);
}

class _MockImagePicker extends Mock implements ImagePicker {}

class _FakeXFile extends Fake implements XFile {
  _FakeXFile(this.path);

  @override
  final String path;
}
