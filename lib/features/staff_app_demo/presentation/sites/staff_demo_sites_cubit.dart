import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

enum StaffDemoSitesStatus { initial, loading, ready, error }

class StaffDemoSitesState {
  const StaffDemoSitesState({
    this.status = StaffDemoSitesStatus.initial,
    this.sites = const <StaffDemoSite>[],
    this.errorMessage,
  });

  final StaffDemoSitesStatus status;
  final List<StaffDemoSite> sites;
  final String? errorMessage;

  StaffDemoSitesState copyWith({
    final StaffDemoSitesStatus? status,
    final List<StaffDemoSite>? sites,
    final String? errorMessage,
  }) {
    return StaffDemoSitesState(
      status: status ?? this.status,
      sites: sites ?? this.sites,
      errorMessage: errorMessage,
    );
  }
}

class StaffDemoSitesCubit extends Cubit<StaffDemoSitesState> {
  StaffDemoSitesCubit({required final StaffDemoSiteRepository repository})
    : _repository = repository,
      super(const StaffDemoSitesState());

  final StaffDemoSiteRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: StaffDemoSitesStatus.loading));

    await CubitExceptionHandler.executeAsync<List<StaffDemoSite>>(
      operation: _repository.listSites,
      isAlive: () => !isClosed,
      onSuccess: (final sites) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoSitesStatus.ready,
            sites: sites,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: StaffDemoSitesStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoSitesCubit.load',
    );
  }
}
