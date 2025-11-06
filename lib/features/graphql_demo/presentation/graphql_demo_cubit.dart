import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class GraphqlDemoCubit extends Cubit<GraphqlDemoState> {
  GraphqlDemoCubit({required final GraphqlDemoRepository repository})
    : _repository = repository,
      super(const GraphqlDemoState());

  final GraphqlDemoRepository _repository;

  Future<void> loadInitial() async {
    _emitLoading();
    await CubitExceptionHandler.executeAsync(
      operation: () async {
        final List<GraphqlContinent> continents = await _repository
            .fetchContinents();
        final List<GraphqlCountry> countries = await _repository
            .fetchCountries();
        return (continents: continents, countries: countries);
      },
      onSuccess: (final result) {
        _emitSuccess(
          continents: result.continents,
          countries: result.countries,
        );
      },
      onError: (final String message) {
        // For unknown exceptions, set errorMessage to null to match original behavior
        _emitError(message: null, type: GraphqlDemoErrorType.unknown);
      },
      logContext: 'GraphqlDemoCubit.loadInitial',
      specificExceptionHandlers: {
        GraphqlDemoException: (final error, final stackTrace) {
          final GraphqlDemoException exception = error as GraphqlDemoException;
          _emitError(message: exception.message, type: exception.type);
        },
      },
    );
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
        state.status == ViewStatus.success &&
        state.activeContinentCode == continentCode) {
      return;
    }
    _emitLoading(activeContinentCode: continentCode);
    await CubitExceptionHandler.executeAsync(
      operation: () => _repository.fetchCountries(
        continentCode: continentCode,
      ),
      onSuccess: (final List<GraphqlCountry> countries) {
        _emitSuccess(countries: countries);
      },
      onError: (final String message) {
        // For unknown exceptions, set errorMessage to null to match original behavior
        _emitError(message: null, type: GraphqlDemoErrorType.unknown);
      },
      logContext: 'GraphqlDemoCubit.selectContinent',
      specificExceptionHandlers: {
        GraphqlDemoException: (final error, final stackTrace) {
          final GraphqlDemoException exception = error as GraphqlDemoException;
          _emitError(message: exception.message, type: exception.type);
        },
      },
    );
  }

  void _emitLoading({final String? activeContinentCode}) {
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        errorMessage: null,
        errorType: null,
        activeContinentCode: activeContinentCode ?? state.activeContinentCode,
      ),
    );
  }

  void _emitSuccess({
    final List<GraphqlCountry>? countries,
    final List<GraphqlContinent>? continents,
    final String? activeContinentCode,
  }) {
    final List<GraphqlCountry> resolvedCountries = countries != null
        ? List<GraphqlCountry>.unmodifiable(countries)
        : state.countries;
    final List<GraphqlContinent> resolvedContinents = continents != null
        ? List<GraphqlContinent>.unmodifiable(continents)
        : state.continents;
    emit(
      state.copyWith(
        status: ViewStatus.success,
        countries: resolvedCountries,
        continents: resolvedContinents,
        activeContinentCode: activeContinentCode ?? state.activeContinentCode,
        errorMessage: null,
        errorType: null,
      ),
    );
  }

  void _emitError({
    required final String? message,
    required final GraphqlDemoErrorType? type,
  }) {
    emit(
      state.copyWith(
        status: ViewStatus.error,
        errorMessage: message,
        errorType: type,
      ),
    );
  }
}
