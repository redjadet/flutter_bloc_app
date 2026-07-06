import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_open_entry_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_timeclock_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_timeclock_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthRepo implements AuthRepository {
  _AuthRepo(this._user);

  final AuthUser? _user;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();
}

class _TimeclockRepo implements StaffDemoTimeclockRepository {
  _TimeclockRepo({required this.clockInResult, required this.clockOutResult});

  final StaffDemoClockResult clockInResult;
  final StaffDemoClockResult clockOutResult;

  @override
  Future<StaffDemoClockResult> clockIn() async => clockInResult;

  @override
  Future<StaffDemoClockResult> clockOut() async => clockOutResult;
}

class _LocalStore implements StaffDemoTimeclockLocalStore {
  _LocalStore(this._open);

  StaffDemoOpenEntrySnapshot? _open;

  @override
  Future<void> clearOpenEntry({required final String userId}) async {
    _open = null;
  }

  @override
  Future<StaffDemoOpenEntrySnapshot?> loadOpenEntry({
    required final String userId,
  }) async => _open;

  @override
  Future<void> saveOpenEntry({
    required final String userId,
    required final StaffDemoOpenEntrySnapshot snapshot,
  }) async {
    _open = snapshot;
  }
}

StaffDemoClockResult _clockResult(final String entryId) => StaffDemoClockResult(
  entryId: entryId,
  flags: StaffDemoTimeEntryFlags.none(),
  shiftId: 'shift-1',
  siteId: 'site-1',
  distanceMeters: 12,
  radiusMeters: 100,
);

void main() {
  group('StaffDemoTimeclockCubit', () {
    test('load emits error when user is not signed in', () async {
      final cubit = StaffDemoTimeclockCubit(
        authRepository: _AuthRepo(null),
        repository: _TimeclockRepo(
          clockInResult: _clockResult('in-1'),
          clockOutResult: _clockResult('out-1'),
        ),
        localRepository: _LocalStore(null),
      );

      await cubit.load();

      expect(cubit.state.status, StaffDemoTimeclockStatus.error);
      expect(cubit.state.errorMessage, 'Not signed in.');
      await cubit.close();
    });

    test('load emits ready when no open entry exists', () async {
      final cubit = StaffDemoTimeclockCubit(
        authRepository: _AuthRepo(
          const AuthUser(id: 'user-1', isAnonymous: false),
        ),
        repository: _TimeclockRepo(
          clockInResult: _clockResult('in-1'),
          clockOutResult: _clockResult('out-1'),
        ),
        localRepository: _LocalStore(null),
      );

      await cubit.load();

      expect(cubit.state.status, StaffDemoTimeclockStatus.ready);
      expect(cubit.state.openEntryId, isNull);
      await cubit.close();
    });

    test('load emits clockedIn when open entry exists', () async {
      final cubit = StaffDemoTimeclockCubit(
        authRepository: _AuthRepo(
          const AuthUser(id: 'user-1', isAnonymous: false),
        ),
        repository: _TimeclockRepo(
          clockInResult: _clockResult('in-1'),
          clockOutResult: _clockResult('out-1'),
        ),
        localRepository: _LocalStore(
          StaffDemoOpenEntrySnapshot(
            entryId: 'open-entry',
            clockInAtUtc: DateTime.utc(2026, 1, 1),
            shiftId: 'shift-1',
            siteId: 'site-1',
            payload: const <String, dynamic>{},
          ),
        ),
      );

      await cubit.load();

      expect(cubit.state.status, StaffDemoTimeclockStatus.clockedIn);
      expect(cubit.state.openEntryId, 'open-entry');
      await cubit.close();
    });

    test('clockIn transitions to clockedIn', () async {
      final cubit = StaffDemoTimeclockCubit(
        authRepository: _AuthRepo(
          const AuthUser(id: 'user-1', isAnonymous: false),
        ),
        repository: _TimeclockRepo(
          clockInResult: _clockResult('entry-42'),
          clockOutResult: _clockResult('entry-42'),
        ),
        localRepository: _LocalStore(null),
      );

      await cubit.clockIn();

      expect(cubit.state.status, StaffDemoTimeclockStatus.clockedIn);
      expect(cubit.state.openEntryId, 'entry-42');
      await cubit.close();
    });

    test('clockOut returns to ready', () async {
      final cubit = StaffDemoTimeclockCubit(
        authRepository: _AuthRepo(
          const AuthUser(id: 'user-1', isAnonymous: false),
        ),
        repository: _TimeclockRepo(
          clockInResult: _clockResult('entry-42'),
          clockOutResult: _clockResult('entry-42'),
        ),
        localRepository: _LocalStore(
          StaffDemoOpenEntrySnapshot(
            entryId: 'entry-42',
            clockInAtUtc: DateTime.utc(2026, 1, 1),
            shiftId: 'shift-1',
            siteId: 'site-1',
            payload: const <String, dynamic>{},
          ),
        ),
      );

      await cubit.clockOut();

      expect(cubit.state.status, StaffDemoTimeclockStatus.ready);
      expect(cubit.state.openEntryId, isNull);
      await cubit.close();
    });
  });
}
