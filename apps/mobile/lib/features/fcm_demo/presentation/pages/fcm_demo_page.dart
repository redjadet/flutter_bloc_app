import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/utils/error_handling.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_cubit.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utilities/utilities.dart';

part 'fcm_demo_page.part.dart';

/// FCM demo page: permission, tokens, last message.
///
/// Token visibility policy is injected by the router (flavor-derived) so this
/// view never reads app config singletons. Release builds always mask and never
/// offer copy, regardless of the injected values.
class FcmDemoPage extends StatelessWidget {
  const new({
    required this.maskTokens,
    required this.allowTokenCopy,
    super.key,
  });

  /// Show a masked placeholder instead of raw push tokens (prod flavor).
  final bool maskTokens;

  /// Offer a copy-token action (dev/qa flavors, non-release builds only).
  final bool allowTokenCopy;

  static String _permissionLabel(
    FcmPermissionState state,
    AppLocalizations l10n,
  ) {
    return switch (state) {
      FcmPermissionState.notDetermined => l10n.fcmDemoPermissionNotDetermined,
      FcmPermissionState.authorized => l10n.fcmDemoPermissionAuthorized,
      FcmPermissionState.denied => l10n.fcmDemoPermissionDenied,
      FcmPermissionState.provisional => l10n.fcmDemoPermissionProvisional,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.fcmDemoPageTitle,
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: _FcmDemoBody(
          maskTokens: maskTokens,
          allowTokenCopy: allowTokenCopy,
        ),
      ),
    );
  }
}

class _FcmDemoBody extends StatelessWidget {
  const new({required this.maskTokens, required this.allowTokenCopy});

  final bool maskTokens;
  final bool allowTokenCopy;

  @override
  Widget build(BuildContext context) {
    final viewState = context
        .selectState<
          FcmDemoCubit,
          FcmDemoState,
          ({FcmDemoStatus status, String? errorMessage})
        >(
          selector: (state) =>
              (status: state.status, errorMessage: state.errorMessage),
        );

    if (viewState.status == FcmDemoStatus.loading ||
        viewState.status == FcmDemoStatus.initial) {
      return Padding(
        padding: EdgeInsets.all(context.responsiveGapL),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (viewState.status == FcmDemoStatus.error) {
      return Padding(
        padding: EdgeInsets.all(context.responsiveGapL),
        child: Text(viewState.errorMessage ?? context.l10n.errorUnknown),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: context.responsiveGapL),
        const _PermissionSection(),
        SizedBox(height: context.responsiveGapM),
        _TokenSectionContainer(
          label: context.l10n.fcmDemoFcmTokenLabel,
          selector: (state) => state.fcmToken,
          maskTokens: maskTokens,
          allowTokenCopy: allowTokenCopy,
        ),
        SizedBox(height: context.responsiveGapS),
        _TokenSectionContainer(
          label: context.l10n.fcmDemoApnsTokenLabel,
          selector: (state) => state.apnsToken,
          maskTokens: maskTokens,
          allowTokenCopy: allowTokenCopy,
        ),
        SizedBox(height: context.responsiveGapM),
        const _LastMessageSectionContainer(),
        SizedBox(height: context.responsiveGapL),
        Text(
          context.l10n.fcmDemoScopeNoteIos,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: context.responsiveGapS),
        Text(
          context.l10n.fcmDemoScopeNoteSimulator,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PermissionSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final permissionState = context
        .selectState<FcmDemoCubit, FcmDemoState, FcmPermissionState>(
          selector: (state) => state.permissionState,
        );

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.fcmDemoPermissionLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: context.responsiveGapXS),
          Text(
            FcmDemoPage._permissionLabel(permissionState, l10n),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TokenSectionContainer extends StatelessWidget {
  const new({
    required this.label,
    required this.selector,
    required this.maskTokens,
    required this.allowTokenCopy,
  });

  final String label;
  final String? Function(FcmDemoState state) selector;
  final bool maskTokens;
  final bool allowTokenCopy;

  @override
  Widget build(BuildContext context) {
    final value = context.selectState<FcmDemoCubit, FcmDemoState, String?>(
      selector: selector,
    );
    return _TokenSection(
      label: label,
      value: value,
      l10n: context.l10n,
      maskTokens: maskTokens,
      allowTokenCopy: allowTokenCopy,
    );
  }
}

class _LastMessageSectionContainer extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final message = context
        .selectState<FcmDemoCubit, FcmDemoState, PushMessage?>(
          selector: (state) => state.lastMessage,
        );
    return _LastMessageSection(message: message, l10n: context.l10n);
  }
}
