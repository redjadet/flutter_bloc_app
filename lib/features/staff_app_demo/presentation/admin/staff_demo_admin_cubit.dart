import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/admin/staff_demo_admin_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class StaffDemoAdminCubit extends Cubit<StaffDemoAdminState> {
  StaffDemoAdminCubit({
    required final FirestoreStaffDemoTimeEntriesRepository
    timeEntriesRepository,
  }) : _timeEntriesRepository = timeEntriesRepository,
       super(const StaffDemoAdminState());

  final FirestoreStaffDemoTimeEntriesRepository _timeEntriesRepository;

  Future<void> load() async {
    emit(state.copyWith(status: StaffDemoAdminStatus.loading));
    await CubitExceptionHandler.executeAsync(
      operation: () => _timeEntriesRepository.fetchRecent(limit: 25),
      isAlive: () => !isClosed,
      onSuccess: (final entries) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoAdminStatus.ready,
            recentEntries: entries,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoAdminStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoAdminCubit.load',
    );
  }
}
