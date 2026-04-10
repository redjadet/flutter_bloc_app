import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStaffDemoEventProofRepository extends Mock
    implements StaffDemoEventProofRepository {}

class _MockStaffDemoProofFileStore extends Mock
    implements StaffDemoProofFileStore {}

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

        unawaited(cubit.submit(siteId: 'site1', shiftId: null));
        await Future<void>.delayed(Duration.zero);

        unawaited(cubit.submit(siteId: 'site1', shiftId: null));
        await Future<void>.delayed(Duration.zero);

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
        await Future<void>.delayed(Duration.zero);
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
  });
}
