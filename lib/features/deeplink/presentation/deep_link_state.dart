import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'deep_link_state.freezed.dart';

/// Origin describing how a deep link was received.
enum DeepLinkOrigin { initial, resumed }

/// Union state for the deep link cubit.
@freezed
sealed class DeepLinkState with _$DeepLinkState {
  /// Idle state when no navigation is pending.
  const factory DeepLinkState.idle() = DeepLinkIdle;

  /// Indicates the cubit is preparing deep link subscriptions.
  const factory DeepLinkState.loading() = DeepLinkLoading;

  /// Signals that navigation to [target] should occur.
  const factory DeepLinkState.navigate(
    final DeepLinkTarget target,
    final DeepLinkOrigin origin,
  ) = DeepLinkNavigate;

  /// Emitted when initialization fails or the stream encounters an error.
  const factory DeepLinkState.error(final String message) = DeepLinkError;
}
