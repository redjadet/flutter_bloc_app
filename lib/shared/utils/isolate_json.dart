import 'dart:convert';

import 'package:flutter/foundation.dart';

const int _kIsolateDecodeThreshold = 8 * 1024;

Future<Map<String, dynamic>> decodeJsonMap(final String payload) async {
  if (payload.length < _kIsolateDecodeThreshold) {
    final dynamic decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected a JSON object');
  }

  final dynamic decoded = await compute(_decodeJson, payload);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON object');
}

Future<List<dynamic>> decodeJsonList(final String payload) async {
  if (payload.length < _kIsolateDecodeThreshold) {
    final dynamic decoded = jsonDecode(payload);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected a JSON array');
  }

  final dynamic decoded = await compute(_decodeJson, payload);
  if (decoded is List<dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON array');
}

dynamic _decodeJson(final String payload) => jsonDecode(payload);
