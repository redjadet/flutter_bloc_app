import 'package:flutter/material.dart';

/// Abstraction for persisting and loading theme mode.
abstract class ThemeRepository {
  Future<ThemeMode?> load();
  Future<void> save(ThemeMode mode);
}
