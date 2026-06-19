import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_country_dto.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GraphqlDemoCacheRepository extends HiveRepositoryBase
    implements GraphqlCacheRepository {
  GraphqlDemoCacheRepository({required super.hiveService});

  static const String _boxName = 'graphql_demo_cache';
  static const String _continentsKey = 'continents';
  static const String _countriesPrefix = 'countries';
  static const String _updatedAtKey = 'updatedAt';
  static const String _itemsKey = 'items';

  @override
  String get boxName => _boxName;

  @override
  Future<List<GraphqlContinent>> readContinents({
    final Duration? maxAge,
  }) async => StorageGuard.run<List<GraphqlContinent>>(
    logContext: 'GraphqlDemoCacheRepository.readContinents',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic stored = box.get(_continentsKey);
      if (stored is! Map<dynamic, dynamic>) {
        return const <GraphqlContinent>[];
      }
      final DateTime? updatedAt = _parseUpdatedAt(stored);
      if (_isStale(updatedAt, maxAge)) {
        return const <GraphqlContinent>[];
      }
      final dynamic items = stored[_itemsKey];
      if (items is! List<dynamic>) {
        return const <GraphqlContinent>[];
      }
      return items
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (final json) {
              // Hive returns Map<dynamic, dynamic>, convert to Map<String, dynamic>
              final Map<String, dynamic> typedJson = _convertMapToTyped(json);
              return GraphqlContinentDto.fromJson(typedJson).toDomain();
            },
          )
          .toList(growable: false);
    },
    fallback: () => const <GraphqlContinent>[],
  );

  @override
  Future<void> writeContinents(
    final List<GraphqlContinent> continents,
  ) async {
    await StorageGuard.run<void>(
      logContext: 'GraphqlDemoCacheRepository.writeContinents',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.put(
          _continentsKey,
          <String, dynamic>{
            _updatedAtKey: DateTime.now().toUtc().toIso8601String(),
            _itemsKey: continents.map(_continentToJson).toList(),
          },
        );
      },
    );
  }

  @override
  Future<List<GraphqlCountry>> readCountries({
    final String? continentCode,
    final Duration? maxAge,
  }) async => StorageGuard.run<List<GraphqlCountry>>(
    logContext: 'GraphqlDemoCacheRepository.readCountries',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic stored = box.get(_countriesKey(continentCode));
      if (stored is! Map<dynamic, dynamic>) {
        return const <GraphqlCountry>[];
      }
      final DateTime? updatedAt = _parseUpdatedAt(stored);
      if (_isStale(updatedAt, maxAge)) {
        return const <GraphqlCountry>[];
      }
      final dynamic items = stored[_itemsKey];
      if (items is! List<dynamic>) {
        return const <GraphqlCountry>[];
      }
      return items
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (final json) {
              // Hive returns Map<dynamic, dynamic>, recursively convert to Map<String, dynamic>
              final Map<String, dynamic> typedJson = _convertMapToTyped(json);
              return GraphqlCountryDto.fromJson(typedJson).toDomain();
            },
          )
          .toList(growable: false);
    },
    fallback: () => const <GraphqlCountry>[],
  );

  @override
  Future<void> writeCountries({
    required final List<GraphqlCountry> countries,
    final String? continentCode,
  }) async {
    await StorageGuard.run<void>(
      logContext: 'GraphqlDemoCacheRepository.writeCountries',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.put(
          _countriesKey(continentCode),
          <String, dynamic>{
            _updatedAtKey: DateTime.now().toUtc().toIso8601String(),
            _itemsKey: countries.map(_countryToJson).toList(),
          },
        );
      },
    );
  }

  String _countriesKey(final String? continentCode) {
    final String normalized = (continentCode ?? 'all').trim();
    final String suffix = normalized.isEmpty ? 'all' : normalized;
    return '$_countriesPrefix:$suffix';
  }

  @override
  Future<void> clear() async {
    await StorageGuard.run<void>(
      logContext: 'GraphqlDemoCacheRepository.clear',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.clear();
      },
    );
  }

  Map<String, dynamic> _continentToJson(final GraphqlContinent continent) =>
      <String, dynamic>{
        'code': continent.code,
        'name': continent.name,
      };

  Map<String, dynamic> _countryToJson(final GraphqlCountry country) =>
      <String, dynamic>{
        'code': country.code,
        'name': country.name,
        'capital': country.capital,
        'currency': country.currency,
        'emoji': country.emoji,
        'continent': _continentToJson(country.continent),
      };

  DateTime? _parseUpdatedAt(final Map<dynamic, dynamic> stored) {
    final Object? raw = stored[_updatedAtKey];
    if (raw is! String) return null;
    return DateTime.tryParse(raw);
  }

  bool _isStale(final DateTime? updatedAt, final Duration? maxAge) {
    if (updatedAt == null || maxAge == null) return false;
    return updatedAt.isBefore(DateTime.now().toUtc().subtract(maxAge));
  }

  /// Recursively converts `Map<dynamic, dynamic>` to `Map<String, dynamic>`.
  /// Handles nested maps and lists that may contain maps.
  Map<String, dynamic> _convertMapToTyped(final Map<dynamic, dynamic> source) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<dynamic, dynamic> entry in source.entries) {
      if (entry.key is! String) {
        continue;
      }
      final String key = entry.key as String;
      final dynamic value = entry.value;

      result[key] = switch (value) {
        final Map<dynamic, dynamic> map => _convertMapToTyped(map),
        final List<dynamic> list =>
          list
              .map(
                (final dynamic item) => switch (item) {
                  final Map<dynamic, dynamic> map => _convertMapToTyped(map),
                  _ => item,
                },
              )
              .toList(),
        _ => value,
      };
    }
    return result;
  }
}
