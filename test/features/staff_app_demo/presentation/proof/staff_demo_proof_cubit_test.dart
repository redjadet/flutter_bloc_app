import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStaffDemoEventProofRepository extends Mock
    implements StaffDemoEventProofRepository {}

class _MockStaffDemoProofFileStore extends Mock
    implements StaffDemoProofFileStore {}

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
  });
}
