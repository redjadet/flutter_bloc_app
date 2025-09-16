#!/usr/bin/env dart

import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  final files = [
    'lib/features/chart/domain/chart_point.freezed.dart',
    'lib/features/counter/domain/counter_snapshot.freezed.dart',
    'lib/features/counter/presentation/counter_state.freezed.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      if (kDebugMode) {
        print('File not found: $filePath');
      }
      continue;
    }

    String content = file.readAsStringSync();

    // Fix ChartPoint formatting
    if (filePath.contains('chart_point')) {
      content = content.replaceAll(
        ' DateTime get date; double get value;',
        ' DateTime get date;\n double get value;',
      );
    }

    // Fix CounterSnapshot formatting
    if (filePath.contains('counter_snapshot')) {
      content = content.replaceAll(
        ' int get count; DateTime? get lastChanged;',
        ' int get count;\n DateTime? get lastChanged;',
      );
    }

    // Fix CounterState formatting
    if (filePath.contains('counter_state')) {
      content = content.replaceAll(
        ' int get count; DateTime? get lastChanged; int get countdownSeconds; bool get isAutoDecrementActive; CounterError? get error; CounterStatus get status;',
        ' int get count;\n DateTime? get lastChanged;\n int get countdownSeconds;\n bool get isAutoDecrementActive;\n CounterError? get error;\n CounterStatus get status;',
      );
    }

    // Fix concrete class implementations
    content = content.replaceAll(
      'class _ChartPoint implements ChartPoint {',
      'class _ChartPoint implements ChartPoint, _\$ChartPoint {',
    );

    content = content.replaceAll(
      'class _CounterSnapshot implements CounterSnapshot {',
      'class _CounterSnapshot implements CounterSnapshot, _\$CounterSnapshot {',
    );

    content = content.replaceAll(
      'class _CounterState extends CounterState {',
      'class _CounterState extends CounterState implements _\$CounterState {',
    );

    file.writeAsStringSync(content);
    if (kDebugMode) {
      print('Fixed formatting in: $filePath');
    }
  }

  if (kDebugMode) {
    print('Freezed formatting fixes applied successfully!');
  }
}
