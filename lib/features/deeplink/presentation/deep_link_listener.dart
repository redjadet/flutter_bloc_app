import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_cubit.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_state.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_target_extensions.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:go_router/go_router.dart';

/// Listens for deep link events and navigates using the provided [GoRouter].
class DeepLinkListener extends StatelessWidget {
  const DeepLinkListener({
    required this.router,
    required this.child,
    required this.service,
    required this.parser,
    super.key,
  });

  final GoRouter router;
  final Widget child;
  final DeepLinkService service;
  final DeepLinkParser parser;

  @override
  Widget build(final BuildContext context) =>
      BlocProviderHelpers.withAsyncInit<DeepLinkCubit>(
        create: () => DeepLinkCubit(
          service: service,
          parser: parser,
        ),
        init: (cubit) => cubit.initialize(),
        child: BlocListener<DeepLinkCubit, DeepLinkState>(
          listenWhen: (final previous, final current) =>
              current is DeepLinkNavigate,
          listener: (final context, final state) async {
            final DeepLinkNavigate navigate = state as DeepLinkNavigate;
            AppLogger.info('Navigating to: ${navigate.target.location}');

            await NavigationUtils.safeGo(
              context,
              router: router,
              location: navigate.target.location,
              logContext: 'DeepLinkListener.navigate',
              onSkipped: () => AppLogger.debug(
                'Skipping deep link navigation – context no longer mounted',
              ),
            );
          },
          child: child,
        ),
      );
}
