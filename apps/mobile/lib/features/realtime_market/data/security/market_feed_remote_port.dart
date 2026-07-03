/// Exchange-style remote feed (not implemented for the Hive + simulator demo).
abstract interface class MarketFeedRemotePort {
  Stream<void> watch();
}

/// Stub remote port — simulator replaces live connectivity.
final class NoopMarketFeedRemotePort implements MarketFeedRemotePort {
  @override
  Stream<void> watch() => const Stream<void>.empty();
}
