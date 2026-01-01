import 'dart:convert';

import 'package:flutter/foundation.dart';

const int _kIsolateDecodeThreshold = 8 * 1024;
const int _kIsolateEncodeSmallCollectionMax = 20;

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

/// Encodes a JSON-serializable object to a JSON string in an isolate if the
/// serialized size is expected to be large.
///
/// Uses `compute()` for objects that, when encoded, are larger than
/// `_kIsolateDecodeThreshold` (8KB). For smaller objects, encoding happens
/// synchronously on the current isolate.
///
/// This is useful for size estimation operations that don't need the result
/// immediately, such as cache size calculations.
Future<String> encodeJsonIsolate(final dynamic object) async {
  if (object is String) {
    if (object.length < _kIsolateDecodeThreshold) {
      return object;
    }
    return compute(_encodeJson, object);
  }

  if (object is List<dynamic>) {
    if (object.length < _kIsolateEncodeSmallCollectionMax) {
      return jsonEncode(object);
    }
  }

  if (object is Map<dynamic, dynamic>) {
    if (object.length < _kIsolateEncodeSmallCollectionMax) {
      return jsonEncode(object);
    }
  }

  return compute(_encodeJson, object);
}

String _encodeJson(final dynamic object) => jsonEncode(object);
