import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_app_error_mapper.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/app_error.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';

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
      onSuccess: (final result) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        _emitSuccess(
          continents: result.continents,
          countries: result.countries,
          source: _repository.lastSource,
        );
      },
      onAppError: (final appError) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        latestError = appError;
      },
      onError: (final message) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        _emitError(
          message: message,
          type: GraphqlDemoErrorType.unknown,
          lastError: latestError,
        );
      },
      logContext: 'GraphqlDemoCubit.loadInitial',
      specificExceptionHandlers: {
        GraphqlDemoException: (final error, final stackTrace) {
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
    final String? continentCode, {
    final bool force = false,
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
      onSuccess: (final countries) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        _emitSuccess(
          countries: countries,
          activeContinentCode: continentCode,
          shouldUpdateActiveContinent: true,
          source: _repository.lastSource,
        );
      },
      onAppError: (final appError) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        latestError = appError;
      },
      onError: (final message) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        _emitError(
          message: message,
          type: GraphqlDemoErrorType.unknown,
          lastError: latestError,
        );
      },
      logContext: 'GraphqlDemoCubit.selectContinent',
      specificExceptionHandlers: {
        GraphqlDemoException: (final error, final stackTrace) {
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
    final String? activeContinentCode,
    final bool shouldUpdateActiveContinent = false,
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
    final List<GraphqlCountry>? countries,
    final List<GraphqlContinent>? continents,
    final String? activeContinentCode,
    final GraphqlDataSource? source,
    final bool shouldUpdateActiveContinent = false,
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
    required final String? message,
    required final GraphqlDemoErrorType? type,
    final AppError? lastError,
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
