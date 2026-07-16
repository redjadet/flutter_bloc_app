// Fixture: production-style fallback — must fail the adhoc Dio guard.
import 'package:dio/dio.dart';

class BadRepository {
  BadRepository({Dio? client}) : _client = client ?? Dio();

  final Dio _client;
}
