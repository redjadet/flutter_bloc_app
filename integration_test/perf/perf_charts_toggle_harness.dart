import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

typedef ZoomChildBuilder =
    Widget Function(
      BuildContext context, {
      required bool zoomEnabled,
    });

class MinimalChartToggleHarness extends StatefulWidget {
  const MinimalChartToggleHarness({
    required this.childBuilder,
    super.key,
  });

  final ZoomChildBuilder childBuilder;

  @override
  State<MinimalChartToggleHarness> createState() =>
      _MinimalChartToggleHarnessState();
}

class _MinimalChartToggleHarnessState extends State<MinimalChartToggleHarness> {
  bool _zoomEnabled = false;

  @override
  Widget build(final BuildContext context) => Scaffold(
    body: Column(
      children: <Widget>[
        SwitchListTile.adaptive(
          value: _zoomEnabled,
          onChanged: (final value) => setState(() => _zoomEnabled = value),
          title: const Text('Enable zoom'),
        ),
        Expanded(
          child: RepaintBoundary(
            child: widget.childBuilder(context, zoomEnabled: _zoomEnabled),
          ),
        ),
      ],
    ),
  );
}

Widget buildPlaceholderChart(
  final BuildContext context, {
  required final bool zoomEnabled,
}) => InteractiveViewer(
  panEnabled: zoomEnabled,
  scaleEnabled: zoomEnabled,
  maxScale: 6,
  boundaryMargin: const EdgeInsets.all(24),
  child: Center(
    child: Container(
      width: 280,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        zoomEnabled ? 'ZOOM ON' : 'ZOOM OFF',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    ),
  ),
);

Widget buildPlaceholderNoInteractiveViewer(
  final BuildContext context, {
  required final bool zoomEnabled,
}) => Center(
  child: Container(
    width: 280,
    height: 180,
    decoration: BoxDecoration(
      color: Colors.blueGrey.shade200,
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: Text(
      zoomEnabled ? 'ZOOM ON' : 'ZOOM OFF',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
  ),
);

Widget buildConstantChild(
  final BuildContext context, {
  required final bool zoomEnabled,
}) => const SizedBox.expand();

class BareLineChart extends StatelessWidget {
  const BareLineChart({
    required this.data,
    super.key,
  });

  final LineChartData data;

  @override
  Widget build(final BuildContext context) => Center(
    child: SizedBox(
      width: 320,
      height: 220,
      child: LineChart(data),
    ),
  );
}
