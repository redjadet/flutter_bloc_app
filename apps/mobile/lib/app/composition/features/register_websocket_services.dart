import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/websocket/data/echo_websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';

/// Registers websocket repository.
void registerWebSocketServices() {
  registerLazySingletonIfAbsent<WebsocketRepository>(
    EchoWebsocketRepository.new,
    dispose: (final repository) => repository.dispose(),
  );
}
