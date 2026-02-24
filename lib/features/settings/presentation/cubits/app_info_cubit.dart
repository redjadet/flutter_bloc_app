import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info_cubit.freezed.dart';

class AppInfoCubit extends Cubit<AppInfoState> {
  AppInfoCubit({required final AppInfoRepository repository})
    : _repository = repository,
      super(const AppInfoState());

  final AppInfoRepository _repository;

  Future<void> load() async {
    if (state.status.isLoading) return;
    if (isClosed) return;

    emit(state.copyWith(status: ViewStatus.loading, errorMessage: null));

    await CubitExceptionHandler.executeAsync(
      operation: _repository.load,
      isAlive: () => !isClosed,
      onSuccess: (final info) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.success,
            info: info,
            errorMessage: null,
          ),
        );
      },
      onError: (final errorMessage) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: errorMessage,
          ),
        );
      },
      logContext: 'AppInfoCubit.load',
    );
  }
}

@freezed
abstract class AppInfoState with _$AppInfoState {
  const factory AppInfoState({
    @Default(ViewStatus.initial) final ViewStatus status,
    final AppInfo? info,
    final String? errorMessage,
  }) = _AppInfoState;
}
