import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_cubit.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_state.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_target_extensions.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:go_router/go_router.dart';

/// Listens for deep link events and navigates using the provided [GoRouter].
class DeepLinkListener extends StatelessWidget {
  const DeepLinkListener({
    required this.router,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Widget child;

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = DeepLinkCubit(
        service: getIt<DeepLinkService>(),
        parser: getIt<DeepLinkParser>(),
      );
      unawaited(cubit.initialize());
      return cubit;
    },
    child: BlocListener<DeepLinkCubit, DeepLinkState>(
      listenWhen: (final previous, final current) =>
          current is DeepLinkNavigate,
      listener: (final context, final state) {
        final DeepLinkNavigate navigate = state as DeepLinkNavigate;
        AppLogger.info('Navigating to: ${navigate.target.location}');

        // Add a small delay to ensure the router is ready
        // Check if context is still mounted before navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            // Check if context is still mounted before navigation
            if (!context.mounted) {
              AppLogger.debug(
                'Skipping deep link navigation – context no longer mounted',
              );
              return;
            }
            router.go(navigate.target.location);
            AppLogger.info('Navigation completed successfully');
          } on Exception catch (e) {
            AppLogger.error('Navigation failed', e);
          }
        });
      },
      child: child,
    ),
  );
}
