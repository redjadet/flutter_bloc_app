import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_line_graph.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

import '../test_harness.dart';
import 'perf_charts_toggle_harness.dart';
import 'perf_helpers.dart';

part 'perf_charts_traces_impl.part.dart';

Future<void> captureChartModeIsolationTraces({
  required final IntegrationTestWidgetsFlutterBinding binding,
  required final WidgetTester tester,
}) => _captureChartModeIsolationTracesImpl(
  binding: binding,
  tester: tester,
);

Map<String, dynamic> chartModeIsolationMeta() => _chartModeIsolationMetaImpl();
