import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';

class AppInfoCubit extends Cubit<AppInfoState> {
  AppInfoCubit({required final AppInfoRepository repository})
    : _repository = repository,
      super(const AppInfoState());

  final AppInfoRepository _repository;

  Future<void> load() async {
    if (state.status == AppInfoStatus.loading) return;

    emit(state.copyWith(status: AppInfoStatus.loading, clearError: true));

    try {
      final AppInfo info = await _repository.load();
      emit(
        state.copyWith(
          status: AppInfoStatus.success,
          info: info,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppInfoStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}

enum AppInfoStatus { initial, loading, success, failure }

class AppInfoState extends Equatable {
  const AppInfoState({
    this.status = AppInfoStatus.initial,
    this.info,
    this.errorMessage,
  });

  final AppInfoStatus status;
  final AppInfo? info;
  final String? errorMessage;

  AppInfoState copyWith({
    final AppInfoStatus? status,
    final AppInfo? info,
    final bool clearInfo = false,
    final String? errorMessage,
    final bool clearError = false,
  }) => AppInfoState(
    status: status ?? this.status,
    info: clearInfo ? null : (info ?? this.info),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => <Object?>[status, info, errorMessage];
}
