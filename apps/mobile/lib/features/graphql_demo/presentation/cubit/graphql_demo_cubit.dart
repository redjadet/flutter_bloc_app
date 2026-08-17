import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/cubit/graphql_demo_state.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_app_error_mapper.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';
import 'package:utilities/utilities.dart';

class GraphqlDemoCubit extends Cubit<GraphqlDemoState> {
  GraphqlDemoCubit({required this._repository})
    : super(const GraphqlDemoState());

  final GraphqlDemoRepository _repository;
  final RequestIdGuard _loadGuard = RequestIdGuard();

  Future<void> loadInitial() async {
    if (isClosed) return;
    final int requestId = _loadGuard.next();
    _emitLoading();
    AppError? latestError;
    await CubitExceptionHandler.executeAsync(
      operation: () async {
        final List<GraphqlContinent> continents = await _repository
            .fetchContinents();
        final List<GraphqlCountry> countries = await _repository
            .fetchCountries();
        return (continents: continents, countries: countries);
      },
      isAlive: () => !isClosed,
      onSuccess: (result) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        _emitSuccess(
          continents: result.continents,
          countries: result.countries,
          source: _repository.lastSource,
        );
      },
      onAppError: (appError) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        latestError = appError;
      },
      onError: (message) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        _emitError(
          message: message,
          type: GraphqlDemoErrorType.unknown,
          lastError: latestError,
        );
      },
      logContext: 'GraphqlDemoCubit.loadInitial',
      specificExceptionHandlers: {
        GraphqlDemoException: (error, stackTrace) {
          if (isClosed || !_loadGuard.isCurrent(requestId)) return;
          final GraphqlDemoException exception = error as GraphqlDemoException;
          _emitError(
            message: exception.message,
            type: exception.type,
            lastError: graphqlDemoAppErrorFromException(exception),
          );
        },
      },
    );
  }

  Future<void> refresh() async {
    if (isClosed) return;
    final String? code = state.activeContinentCode;
    await selectContinent(code, force: true);
  }

  Future<void> selectContinent(
    String? continentCode, {
    bool force = false,
  }) async {
    if (isClosed) return;
    if (!force &&
        state.status == ViewStatus.success &&
        state.activeContinentCode == continentCode) {
      return;
    }
    final int requestId = _loadGuard.next();
    _emitLoading(
      activeContinentCode: continentCode,
      shouldUpdateActiveContinent: true,
    );
    AppError? latestError;
    await CubitExceptionHandler.executeAsync(
      operation: () => _repository.fetchCountries(
        continentCode: continentCode,
      ),
      isAlive: () => !isClosed,
      onSuccess: (countries) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        _emitSuccess(
          countries: countries,
          activeContinentCode: continentCode,
          shouldUpdateActiveContinent: true,
          source: _repository.lastSource,
        );
      },
      onAppError: (appError) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        latestError = appError;
      },
      onError: (message) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        _emitError(
          message: message,
          type: GraphqlDemoErrorType.unknown,
          lastError: latestError,
        );
      },
      logContext: 'GraphqlDemoCubit.selectContinent',
      specificExceptionHandlers: {
        GraphqlDemoException: (error, stackTrace) {
          if (isClosed || !_loadGuard.isCurrent(requestId)) return;
          final GraphqlDemoException exception = error as GraphqlDemoException;
          _emitError(
            message: exception.message,
            type: exception.type,
            lastError: graphqlDemoAppErrorFromException(exception),
          );
        },
      },
    );
  }

  void _emitLoading({
    String? activeContinentCode,
    bool shouldUpdateActiveContinent = false,
  }) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        errorMessage: null,
        errorType: null,
        lastError: null,
        activeContinentCode: shouldUpdateActiveContinent
            ? activeContinentCode
            : state.activeContinentCode,
      ),
    );
  }

  void _emitSuccess({
    List<GraphqlCountry>? countries,
    List<GraphqlContinent>? continents,
    String? activeContinentCode,
    GraphqlDataSource? source,
    bool shouldUpdateActiveContinent = false,
  }) {
    final List<GraphqlCountry> resolvedCountries = countries != null
        ? List<GraphqlCountry>.unmodifiable(countries)
        : state.countries;
    final List<GraphqlContinent> resolvedContinents = continents != null
        ? List<GraphqlContinent>.unmodifiable(continents)
        : state.continents;
    if (isClosed) return;
    emit(
      state.copyWith(
        status: ViewStatus.success,
        countries: resolvedCountries,
        continents: resolvedContinents,
        activeContinentCode: shouldUpdateActiveContinent
            ? activeContinentCode
            : state.activeContinentCode,
        errorMessage: null,
        errorType: null,
        lastError: null,
        dataSource: source ?? state.dataSource,
      ),
    );
  }

  void _emitError({
    required String? message,
    required GraphqlDemoErrorType? type,
    AppError? lastError,
  }) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: ViewStatus.error,
        errorMessage: message,
        errorType: type,
        lastError: lastError ?? graphqlDemoAppErrorFromType(type, message),
      ),
    );
  }
}
