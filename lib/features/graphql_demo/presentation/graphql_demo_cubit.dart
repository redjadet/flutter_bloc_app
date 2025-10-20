import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_state.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class GraphqlDemoCubit extends Cubit<GraphqlDemoState> {
  GraphqlDemoCubit({required final GraphqlDemoRepository repository})
    : _repository = repository,
      super(const GraphqlDemoState());

  final GraphqlDemoRepository _repository;

  Future<void> loadInitial() async {
    emit(
      state.copyWith(
        status: GraphqlDemoStatus.loading,
        errorMessage: null,
        errorType: null,
      ),
    );
    try {
      final List<GraphqlContinent> continents = await _repository
          .fetchContinents();
      final List<GraphqlCountry> countries = await _repository.fetchCountries();
      emit(
        state.copyWith(
          status: GraphqlDemoStatus.success,
          continents: List<GraphqlContinent>.unmodifiable(continents),
          countries: List<GraphqlCountry>.unmodifiable(countries),
          activeContinentCode: null,
          errorMessage: null,
          errorType: null,
        ),
      );
    } on GraphqlDemoException catch (error, stackTrace) {
      AppLogger.error('GraphqlDemoCubit.loadInitial failed', error, stackTrace);
      emit(
        state.copyWith(
          status: GraphqlDemoStatus.error,
          errorMessage: error.message,
          errorType: error.type,
        ),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error('GraphqlDemoCubit.loadInitial failed', error, stackTrace);
      emit(
        state.copyWith(
          status: GraphqlDemoStatus.error,
          errorMessage: _friendlyMessage(error),
          errorType: _resolveErrorType(error),
        ),
      );
    }
  }

  Future<void> refresh() async {
    final String? code = state.activeContinentCode;
    await selectContinent(code, force: true);
  }

  Future<void> selectContinent(
    final String? continentCode, {
    final bool force = false,
  }) async {
    if (!force &&
        state.status == GraphqlDemoStatus.success &&
        state.activeContinentCode == continentCode) {
      return;
    }
    emit(
      state.copyWith(
        status: GraphqlDemoStatus.loading,
        errorMessage: null,
        errorType: null,
        activeContinentCode: continentCode,
      ),
    );
    try {
      final List<GraphqlCountry> countries = await _repository.fetchCountries(
        continentCode: continentCode,
      );
      emit(
        state.copyWith(
          status: GraphqlDemoStatus.success,
          countries: List<GraphqlCountry>.unmodifiable(countries),
          errorMessage: null,
          errorType: null,
        ),
      );
    } on GraphqlDemoException catch (error, stackTrace) {
      AppLogger.error(
        'GraphqlDemoCubit.selectContinent failed',
        error,
        stackTrace,
      );
      emit(
        state.copyWith(
          status: GraphqlDemoStatus.error,
          errorMessage: error.message,
          errorType: error.type,
        ),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'GraphqlDemoCubit.selectContinent failed',
        error,
        stackTrace,
      );
      emit(
        state.copyWith(
          status: GraphqlDemoStatus.error,
          errorMessage: _friendlyMessage(error),
          errorType: _resolveErrorType(error),
        ),
      );
    }
  }

  String? _friendlyMessage(final Object error) {
    if (error is GraphqlDemoException) {
      return error.message;
    }
    return null;
  }

  GraphqlDemoErrorType _resolveErrorType(final Object error) {
    if (error is GraphqlDemoException) {
      return error.type;
    }
    return GraphqlDemoErrorType.unknown;
  }
}
