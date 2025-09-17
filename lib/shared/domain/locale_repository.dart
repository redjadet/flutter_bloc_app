import 'package:flutter/material.dart';

/// Abstraction for persisting and loading a user-selected app locale.
abstract class LocaleRepository {
  Future<Locale?> load();
  Future<void> save(Locale? locale);
}
