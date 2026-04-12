import 'dart:async';

import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStaffDemoFormsRepository extends Mock
    implements StaffDemoFormsRepository {}

void main() {
  group('StaffDemoFormsCubit', () {
    test(
      'ignores duplicate availability submits while a request is in flight',
      () async {
        final authRepository = _MockAuthRepository();
        final repository = _MockStaffDemoFormsRepository();
        final completer = Completer<void>();

        when(() => authRepository.currentUser).thenReturn(
          const AuthUser(
            id: 'u1',
            email: 'user@example.com',
            isAnonymous: false,
          ),
        );
        when(
          () => repository.submitAvailability(
            userId: any(named: 'userId'),
            weekStartUtc: any(named: 'weekStartUtc'),
            availabilityByIsoDate: any(named: 'availabilityByIsoDate'),
          ),
        ).thenAnswer((_) => completer.future);

        final cubit = StaffDemoFormsCubit(
          authRepository: authRepository,
          repository: repository,
        );
        addTearDown(cubit.close);

        unawaited(
          cubit.submitAvailability(
            weekStartUtc: DateTime.utc(2026, 4, 6),
            availabilityByIsoDate: const <String, bool>{'2026-04-06': true},
          ),
        );
        await Future<void>.delayed(Duration.zero);

        unawaited(
          cubit.submitAvailability(
            weekStartUtc: DateTime.utc(2026, 4, 6),
            availabilityByIsoDate: const <String, bool>{'2026-04-06': true},
          ),
        );
        await Future<void>.delayed(Duration.zero);

        verify(
          () => repository.submitAvailability(
            userId: 'u1',
            weekStartUtc: DateTime.utc(2026, 4, 6),
            availabilityByIsoDate: const <String, bool>{'2026-04-06': true},
          ),
        ).called(1);

        completer.complete();
        await Future<void>.delayed(Duration.zero);
      },
    );

    test('submits manager report through the repository', () async {
      final authRepository = _MockAuthRepository();
      final repository = _MockStaffDemoFormsRepository();

      when(() => authRepository.currentUser).thenReturn(
        const AuthUser(id: 'u1', email: 'user@example.com', isAnonymous: false),
      );
      when(
        () => repository.submitManagerReport(
          userId: any(named: 'userId'),
          siteId: any(named: 'siteId'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async {});

      final cubit = StaffDemoFormsCubit(
        authRepository: authRepository,
        repository: repository,
      );
      addTearDown(cubit.close);

      await cubit.submitManagerReport(siteId: 'site1', notes: 'Note text');

      expect(cubit.state.status, StaffDemoFormsStatus.success);
      expect(
        cubit.state.lastSuccessKind,
        StaffDemoFormsSuccessKind.managerReportSubmitted,
      );
      verify(
        () => repository.submitManagerReport(
          userId: 'u1',
          siteId: 'site1',
          notes: 'Note text',
        ),
      ).called(1);
    });
  });
}
