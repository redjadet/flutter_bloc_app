/// Deferred library for Charts feature.
///
/// This library is loaded on-demand to reduce initial app bundle size.
/// The fl_chart package is heavy and only needed when the user navigates
/// to the charts page.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/chart/presentation/pages/chart_page.dart';

/// Builds the Charts page with lazy-loaded repository injection.
///
/// This function is called after the deferred library is loaded.
/// It creates a [ChartPage] with the chart repository from DI.
Widget buildChartPage() => ChartPage(
  repository: getIt<ChartRepository>(),
);
