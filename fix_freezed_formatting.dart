#!/usr/bin/env dart

import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  for (final filePath in _targetFiles) {
    final file = File(filePath);
    if (!file.existsSync()) {
      if (kDebugMode) {
        print('File not found: $filePath');
      }
      continue;
    }

    String content = file.readAsStringSync();

    for (final _Replacement replacement in _replacements) {
      if (replacement.shouldApply(filePath)) {
        content = replacement.apply(content);
      }
    }

    file.writeAsStringSync(content);
    if (kDebugMode) {
      print('Fixed formatting in: $filePath');
    }
  }

  if (kDebugMode) {
    print('Freezed formatting fixes applied successfully!');
  }
}

const List<String> _targetFiles = <String>[
  'lib/features/chart/domain/chart_point.freezed.dart',
  'lib/features/counter/domain/counter_snapshot.freezed.dart',
  'lib/features/counter/presentation/counter_state.freezed.dart',
];

/// Holds replacement patterns and the file suffix that activates them.
class _Replacement {
  const _Replacement({
    required this.trigger,
    required this.oldValue,
    required this.newValue,
  });

  final String trigger;
  final String oldValue;
  final String newValue;

  bool shouldApply(final String filePath) => filePath.contains(trigger);

  String apply(final String content) => content.replaceAll(oldValue, newValue);
}

const String _chartPointContract =
    ' DateTime get date;'
    ' double get value;';

const String _chartPointMultilineContract =
    ' DateTime get date;\n double get value;';

const String _counterSnapshotContract =
    ' int get count;'
    ' DateTime? get lastChanged;';

const String _counterSnapshotMultilineContract =
    ' int get count;\n DateTime? get lastChanged;';

const String _counterStateContract =
    ' int get count;'
    ' DateTime? get lastChanged;'
    ' int get countdownSeconds;'
    ' CounterError? get error;'
    ' CounterStatus get status;';

const String _counterStateMultilineContract =
    ' int get count;\n'
    ' DateTime? get lastChanged;\n'
    ' int get countdownSeconds;\n'
    ' CounterError? get error;\n'
    ' CounterStatus get status;';

const List<_Replacement> _replacements = <_Replacement>[
  _Replacement(
    trigger: 'chart_point',
    oldValue: _chartPointContract,
    newValue: _chartPointMultilineContract,
  ),
  _Replacement(
    trigger: 'counter_snapshot',
    oldValue: _counterSnapshotContract,
    newValue: _counterSnapshotMultilineContract,
  ),
  _Replacement(
    trigger: 'counter_state',
    oldValue: _counterStateContract,
    newValue: _counterStateMultilineContract,
  ),
  _Replacement(
    trigger: 'chart_point',
    oldValue: 'class _ChartPoint implements ChartPoint {',
    newValue: 'class _ChartPoint implements ChartPoint, _\$ChartPoint {',
  ),
  _Replacement(
    trigger: 'counter_snapshot',
    oldValue: 'class _CounterSnapshot implements CounterSnapshot {',
    newValue:
        'class _CounterSnapshot implements CounterSnapshot, _\$CounterSnapshot {',
  ),
  _Replacement(
    trigger: 'counter_state',
    oldValue: 'class _CounterState extends CounterState {',
    newValue:
        'class _CounterState extends CounterState implements _\$CounterState {',
  ),
];
