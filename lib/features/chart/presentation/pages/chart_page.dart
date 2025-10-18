import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/chart.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key, ChartRepository? repository})
    : _repository = repository;

  final ChartRepository? _repository;

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late final ChartRepository _repository;
  late Future<List<ChartPoint>> _future;
  bool _zoomEnabled = false;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? DelayedChartRepository();
    _future = _repository.fetchTrendingCounts();
  }

  Future<void> _handleRefresh() {
    final next = _repository.fetchTrendingCounts();
    setState(() {
      _future = next;
    });
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CommonPageLayout(
      title: l10n.chartPageTitle,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<List<ChartPoint>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const ChartLoadingList();
            }
            if (snapshot.hasError) {
              return ChartMessageList(message: l10n.chartPageError);
            }
            final points = snapshot.data ?? const [];
            if (points.isEmpty) {
              return ChartMessageList(message: l10n.chartPageEmpty);
            }
            final locale = Localizations.localeOf(context).toString();
            final dateFormat = DateFormat.Md(locale);
            return ChartContentList(
              l10n: l10n,
              points: points,
              dateFormat: dateFormat,
              zoomEnabled: _zoomEnabled,
              onZoomChanged: (value) => setState(() => _zoomEnabled = value),
            );
          },
        ),
      ),
    );
  }
}
