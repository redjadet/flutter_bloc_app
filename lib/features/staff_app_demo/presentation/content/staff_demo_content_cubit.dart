import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/content/staff_demo_content_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class StaffDemoContentCubit extends Cubit<StaffDemoContentState> {
  StaffDemoContentCubit({required final StaffDemoContentRepository repository})
    : _repository = repository,
      super(const StaffDemoContentState());

  final StaffDemoContentRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: StaffDemoContentStatus.loading));
    await CubitExceptionHandler.executeAsync<List<StaffDemoContentItem>>(
      operation: _repository.listPublished,
      isAlive: () => !isClosed,
      onSuccess: (final items) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoContentStatus.ready,
            items: items,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoContentStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoContentCubit.load',
    );
  }

  Future<Uri?> resolveUrl(final StaffDemoContentItem item) async {
    try {
      return await _repository.getDownloadUrl(storagePath: item.storagePath);
    } on Exception {
      return null;
    }
  }
}
