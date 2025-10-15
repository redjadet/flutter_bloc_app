import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';

/// Origin describing how a deep link was received.
enum DeepLinkOrigin { initial, resumed }

/// Base state for the deep link cubit.
sealed class DeepLinkState extends Equatable {
  const DeepLinkState();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Idle state when no navigation is pending.
class DeepLinkIdle extends DeepLinkState {
  const DeepLinkIdle();
}

/// Signals that navigation to [target] should occur.
class DeepLinkNavigate extends DeepLinkState {
  const DeepLinkNavigate(this.target, this.origin);

  final DeepLinkTarget target;
  final DeepLinkOrigin origin;

  @override
  List<Object?> get props => <Object?>[target, origin];
}
