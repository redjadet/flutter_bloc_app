import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/cubit/deep_link_cubit.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/cubit/deep_link_state.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_target_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

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
  Widget build(BuildContext context) =>
      BlocProviderHelpers.withAsyncInit<DeepLinkCubit>(
        create: () => DeepLinkCubit(
          service: service,
          parser: parser,
        ),
        init: (cubit) => cubit.initialize(),
        child: TypeSafeBlocListener<DeepLinkCubit, DeepLinkState>(
          listenWhen: (previous, current) => current is DeepLinkNavigate,
          listener: (context, state) async {
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
