/// Deferred library for WebSocket feature.
///
/// This library is loaded on-demand to reduce initial app bundle size.
/// The web_socket_channel package and WebSocket connection libraries are
/// only needed when the user navigates to the WebSocket demo page.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_cubit.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/pages/websocket_demo_page.dart';

/// Builds the WebSocket demo page with lazy-loaded cubit initialization.
///
/// This function is called after the deferred library is loaded.
/// It creates a [WebsocketCubit] and wraps the page in a BlocProvider.
Widget buildWebsocketPage() => BlocProvider(
  create: (_) => WebsocketCubit(repository: getIt<WebsocketRepository>()),
  child: const WebsocketDemoPage(),
);
