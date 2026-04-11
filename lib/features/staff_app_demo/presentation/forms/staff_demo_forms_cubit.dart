import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class StaffDemoFormsCubit extends Cubit<StaffDemoFormsState> {
  StaffDemoFormsCubit({
    required final AuthRepository authRepository,
    required final StaffDemoFormsRepository repository,
  }) : _authRepository = authRepository,
       _repository = repository,
       super(const StaffDemoFormsState());

  final AuthRepository _authRepository;
  final StaffDemoFormsRepository _repository;

  String? get _userId => _authRepository.currentUser?.id;

  Future<void> submitAvailability({
    required final DateTime weekStartUtc,
    required final Map<String, bool> availabilityByIsoDate,
  }) async {
    if (state.status == StaffDemoFormsStatus.submitting) {
      return;
    }
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoFormsStatus.error,
          errorMessage: 'Not signed in.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: StaffDemoFormsStatus.submitting));
    await CubitExceptionHandler.executeAsync<void>(
      operation: () => _repository.submitAvailability(
        userId: userId,
        weekStartUtc: weekStartUtc,
        availabilityByIsoDate: availabilityByIsoDate,
      ),
      isAlive: () => !isClosed,
      onSuccess: (_) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoFormsStatus.success,
            errorMessage: null,
            lastSubmitLabel: 'Availability submitted',
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoFormsStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoFormsCubit.submitAvailability',
    );
  }

  Future<void> submitManagerReport({
    required final String siteId,
    required final String notes,
  }) async {
    if (state.status == StaffDemoFormsStatus.submitting) {
      return;
    }
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoFormsStatus.error,
          errorMessage: 'Not signed in.',
        ),
      );
      return;
    }
    if (siteId.trim().isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoFormsStatus.error,
          errorMessage: 'Site ID is required.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: StaffDemoFormsStatus.submitting));
    await CubitExceptionHandler.executeAsync<void>(
      operation: () => _repository.submitManagerReport(
        userId: userId,
        siteId: siteId.trim(),
        notes: notes.trim(),
      ),
      isAlive: () => !isClosed,
      onSuccess: (_) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoFormsStatus.success,
            errorMessage: null,
            lastSubmitLabel: 'Manager report submitted',
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoFormsStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoFormsCubit.submitManagerReport',
    );
  }
}
