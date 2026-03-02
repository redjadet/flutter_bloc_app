import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lobby_state.freezed.dart';

/// State for the iGaming demo lobby (virtual balance and entry to game).
@freezed
abstract class LobbyState with _$LobbyState {
  const factory LobbyState.initial() = _LobbyInitial;
  const factory LobbyState.loading() = _LobbyLoading;
  const factory LobbyState.ready(final DemoBalance balance) = _LobbyReady;
  const factory LobbyState.error(final String message) = _LobbyError;
}
