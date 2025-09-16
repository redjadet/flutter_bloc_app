import 'dart:convert';

import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

/// Example REST-backed implementation of [CounterRepository].
///
/// This is a scaffold with TODOs. Wire endpoints, auth and models as needed.
class RestCounterRepository implements CounterRepository {
  RestCounterRepository({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl,
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Uri get _counterUri => Uri.parse('$_baseUrl/counter');

  @override
  Future<CounterSnapshot> load() async {
    try {
      // TODO: Add headers/auth when necessary
      final res = await _client.get(_counterUri);
      if (res.statusCode != 200) {
        AppLogger.error(
          'RestCounterRepository.load non-200: ${res.statusCode}',
          null,
          StackTrace.current,
        );
        return const CounterSnapshot(count: 0);
      }
      final Map<String, dynamic> json =
          jsonDecode(res.body) as Map<String, dynamic>;
      final int count = (json['count'] as num?)?.toInt() ?? 0;
      final int? changedMs = (json['last_changed'] as num?)?.toInt();
      final DateTime? lastChanged = changedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(changedMs)
          : null;
      return CounterSnapshot(count: count, lastChanged: lastChanged);
    } catch (e, s) {
      AppLogger.error('RestCounterRepository.load failed', e, s);
      return const CounterSnapshot(count: 0);
    }
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    try {
      // TODO: Add headers/auth when necessary
      final res = await _client.post(
        _counterUri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'count': snapshot.count,
          'last_changed': snapshot.lastChanged?.millisecondsSinceEpoch,
        }),
      );
      if (res.statusCode < 200 || res.statusCode >= 300) {
        AppLogger.error(
          'RestCounterRepository.save non-2xx: ${res.statusCode}',
          null,
          StackTrace.current,
        );
      }
    } catch (e, s) {
      AppLogger.error('RestCounterRepository.save failed', e, s);
    }
  }
}
