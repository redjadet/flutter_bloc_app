// Fixture: bare constructor outside an approved factory — must fail.
import 'package:dio/dio.dart';

class BadBareDio {
  BadBareDio() : client = Dio();

  final Dio client;
}
