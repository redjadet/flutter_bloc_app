import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_timeclock_local_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/timeclock/staff_demo_timeclock_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class StaffDemoTimeclockCubit extends Cubit<StaffDemoTimeclockState> {
  StaffDemoTimeclockCubit({
    required final AuthRepository authRepository,
    required final StaffDemoTimeclockRepository repository,
    required final StaffDemoTimeclockLocalRepository localRepository,
  }) : _authRepository = authRepository,
       _repository = repository,
       _localRepository = localRepository,
       super(const StaffDemoTimeclockState());

  final AuthRepository _authRepository;
  final StaffDemoTimeclockRepository _repository;
  final StaffDemoTimeclockLocalRepository _localRepository;

  String? _userId() => _authRepository.currentUser?.id;

  Future<void> load() async {
    final userId = _userId();
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoTimeclockStatus.error,
          errorMessage: 'Not signed in.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: StaffDemoTimeclockStatus.busy));
    await CubitExceptionHandler.executeAsync<StaffDemoOpenEntrySnapshot?>(
      operation: () => _localRepository.loadOpenEntry(userId: userId),
      isAlive: () => !isClosed,
      onSuccess: (final open) {
        if (isClosed) return;
        if (open == null) {
          emit(
            state.copyWith(
              status: StaffDemoTimeclockStatus.ready,
              openEntryId: null,
              errorMessage: null,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: StaffDemoTimeclockStatus.clockedIn,
            openEntryId: open.entryId,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoTimeclockStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoTimeclockCubit.load',
    );
  }

  Future<void> clockIn() async {
    if (state.status == StaffDemoTimeclockStatus.busy) return;
    emit(state.copyWith(status: StaffDemoTimeclockStatus.busy));
    await CubitExceptionHandler.executeAsync<StaffDemoClockResult>(
      operation: () => _repository.clockIn(),
      isAlive: () => !isClosed,
      onSuccess: (final result) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoTimeclockStatus.clockedIn,
            openEntryId: result.entryId,
            lastResult: result,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoTimeclockStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoTimeclockCubit.clockIn',
    );
  }

  Future<void> clockOut() async {
    if (state.status == StaffDemoTimeclockStatus.busy) return;
    emit(state.copyWith(status: StaffDemoTimeclockStatus.busy));
    await CubitExceptionHandler.executeAsync<StaffDemoClockResult>(
      operation: () => _repository.clockOut(),
      isAlive: () => !isClosed,
      onSuccess: (final result) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoTimeclockStatus.ready,
            openEntryId: null,
            lastResult: result,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoTimeclockStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoTimeclockCubit.clockOut',
    );
  }
}
