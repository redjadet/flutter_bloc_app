import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_cubit.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_state.dart';
import 'package:go_router/go_router.dart';

/// Listens for deep link events and navigates using the provided [GoRouter].
class DeepLinkListener extends StatelessWidget {
  const DeepLinkListener({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeepLinkCubit(
        service: getIt<DeepLinkService>(),
        parser: getIt<DeepLinkParser>(),
      )..initialize(),
      child: BlocListener<DeepLinkCubit, DeepLinkState>(
        listenWhen: (previous, current) => current is DeepLinkNavigate,
        listener: (context, state) {
          final DeepLinkNavigate navigate = state as DeepLinkNavigate;
          router.go(navigate.target.location);
        },
        child: child,
      ),
    );
  }
}
