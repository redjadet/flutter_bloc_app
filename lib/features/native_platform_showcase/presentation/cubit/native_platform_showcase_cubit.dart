import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_native_platform_showcase_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';

class NativePlatformShowcaseCubit extends Cubit<NativePlatformShowcaseState> {
  NativePlatformShowcaseCubit({
    required final LoadNativePlatformShowcaseUseCase loadShowcase,
  }) : this._(loadShowcase);

  NativePlatformShowcaseCubit._(this._loadShowcase)
    : super(const NativePlatformShowcaseState.initial());

  final LoadNativePlatformShowcaseUseCase _loadShowcase;
  bool _loadInFlight = false;

  Future<void> load() async {
    if (isClosed || _loadInFlight) return;
    _loadInFlight = true;
    emit(const NativePlatformShowcaseState.loading());
    try {
      final data = await _loadShowcase();
      if (isClosed) return;
      emit(NativePlatformShowcaseState.loaded(data));
    } on Object {
      if (isClosed) return;
      emit(
        const NativePlatformShowcaseState.error(
          failure: NativePlatformShowcaseFailureKind.loadFailed,
        ),
      );
    } finally {
      _loadInFlight = false;
    }
  }
}
