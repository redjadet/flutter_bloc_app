import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_body.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (_) => RegisterCubit(),
    child: TypeSafeBlocListener<RegisterCubit, RegisterState>(
      listenWhen: (final previous, final current) =>
          previous.submissionStatus != current.submissionStatus,
      listener: (final context, final state) {
        if (state.submissionStatus == RegisterSubmissionStatus.success) {
          _handleSuccess(context, state);
        }
      },
      child: const _RegisterView(),
    ),
  );
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return CommonPageLayout(
      title: l10n.registerTitle,
      appBarBackgroundColor: colorScheme.surface,
      appBarForegroundColor: colorScheme.onSurface,
      cupertinoTitleStyle: theme.textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      useResponsiveBody: false,
      body: const SafeArea(
        child: ResponsiveRegisterBody(),
      ),
    );
  }
}

void _handleSuccess(final BuildContext context, final RegisterState state) {
  final cubit = context.cubit<RegisterCubit>();
  final l10n = context.l10n;
  final displayName = state.fullName.value.trim();

  unawaited(
    showAdaptiveDialog<void>(
      context: context,
      builder: (final dialogContext) {
        final bool isCupertino = PlatformAdaptive.isCupertino(context);
        if (isCupertino) {
          return CupertinoAlertDialog(
            title: Text(l10n.registerDialogTitle),
            content: Text(l10n.registerDialogMessage(displayName)),
            actions: [
              CupertinoDialogAction(
                onPressed: () => NavigationUtils.maybePop(dialogContext),
                child: Text(l10n.registerDialogOk),
              ),
            ],
          );
        }
        return AlertDialog(
          title: Text(l10n.registerDialogTitle),
          content: Text(l10n.registerDialogMessage(displayName)),
          actions: [
            PlatformAdaptive.dialogAction(
              context: dialogContext,
              label: l10n.registerDialogOk,
              onPressed: () => NavigationUtils.maybePop(dialogContext),
            ),
          ],
        );
      },
    ).then((_) {
      if (!cubit.isClosed) {
        cubit.resetSubmissionStatus();
      }
    }),
  );
}
