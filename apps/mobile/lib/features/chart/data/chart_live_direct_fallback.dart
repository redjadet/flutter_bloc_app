import 'package:flutter_bloc_app/features/chart/data/auth_aware_chart_remote_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Tries [fallback] (e.g. CoinGecko) when Edge / Cloud Function did not return
/// usable points.
///
/// Returns a non-empty list on success, or `null` if [fallback] is null, the
/// fetch returns no points, or throws (errors are logged).
///
/// Pass [guardAgainstIdenticalTo] as the hosting repository (`this`) so a bad
/// DI/test wiring that sets `liveDirectFallback` to the same instance cannot
/// recurse.
///
/// Also rejects [AuthAwareChartRemoteRepository] as [fallback], which would
/// re-enter provider selection and can stack-overflow if mis-wired as the
/// “direct” implementation.
Future<List<ChartPoint>?> tryLiveDirectChartPoints({
  required final ChartRemoteRepository? fallback,
  required final String loggerTag,
  final String? successDebugDetail,
  final Object? guardAgainstIdenticalTo,
}) async {
  if (fallback == null) {
    return null;
  }
  final String trimmedTag = loggerTag.trim();
  final String tag = trimmedTag.isEmpty ? 'ChartLiveDirect' : trimmedTag;
  if (fallback is AuthAwareChartRemoteRepository) {
    AppLogger.warning(
      '$tag: liveDirectFallback ignored (AuthAwareChartRemoteRepository; '
      'misconfiguration)',
    );
    return null;
  }
  if (guardAgainstIdenticalTo != null &&
      identical(fallback, guardAgainstIdenticalTo)) {
    AppLogger.warning(
      '$tag: liveDirectFallback ignored (identical to host; misconfiguration)',
    );
    return null;
  }
  try {
    final List<ChartPoint> live = await fallback.fetchTrendingCounts();
    if (live.isEmpty) {
      return null;
    }
    AppLogger.debug(
      '$tag: ${successDebugDetail ?? 'chart data from direct API (CoinGecko)'}',
    );
    return live;
  } on Object catch (error, stackTrace) {
    AppLogger.warning('$tag: live direct fallback failed');
    AppLogger.error('$tag.liveDirectFallback', error, stackTrace);
    return null;
  }
}
