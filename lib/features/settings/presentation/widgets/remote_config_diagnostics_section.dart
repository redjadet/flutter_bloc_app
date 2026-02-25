import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/remote_config_view_data.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

part 'remote_config_diagnostics_section_components.dart';
part 'remote_config_diagnostics_section_models.dart';

class RemoteConfigDiagnosticsSection extends StatefulWidget {
  const RemoteConfigDiagnosticsSection({super.key});

  @override
  State<RemoteConfigDiagnosticsSection> createState() =>
      _RemoteConfigDiagnosticsSectionState();
}

class _RemoteConfigDiagnosticsSectionState
    extends State<RemoteConfigDiagnosticsSection> {
  @override
  void initState() {
    super.initState();
    if (CubitHelpers.isCubitAvailable<RemoteConfigCubit, RemoteConfigState>(
      context,
    )) {
      unawaited(context.cubit<RemoteConfigCubit>().ensureInitialized());
    }
    context.ensureSyncStartedIfAvailable();
  }

  @override
  Widget build(final BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<RemoteConfigCubit, RemoteConfigState>(
      context,
    )) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final double gap = context.responsiveGapS;
    final bool hasSyncStatusCubit =
        CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
          context,
        );

    return SettingsSection(
      title: context.l10n.settingsRemoteConfigSectionTitle,
      child: CommonCard(
        child:
            TypeSafeBlocSelector<
              RemoteConfigCubit,
              RemoteConfigState,
              RemoteConfigViewData
            >(
              selector: RemoteConfigViewData.fromState,
              builder: (final context, final data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (hasSyncStatusCubit)
                    _RemoteConfigSyncStatusBanner(gap: gap),
                  _RemoteConfigStatusBadge(
                    status: data.status,
                    theme: theme,
                  ),
                  if (data.showFlagStatus) ...<Widget>[
                    SizedBox(height: gap),
                    _RemoteConfigFlagRow(
                      isEnabled: data.isAwesomeFeatureEnabled,
                    ),
                  ],
                  if (data.showTestValue) ...<Widget>[
                    SizedBox(height: gap),
                    _RemoteConfigTestValueRow(
                      testValue: data.testValue ?? '',
                    ),
                  ],
                  if (data.showMetadata) ...<Widget>[
                    SizedBox(height: gap),
                    _RemoteConfigMetadataRow(
                      dataSource: data.dataSource,
                      lastSyncedAt: data.lastSyncedAt,
                    ),
                  ],
                  if (data.errorMessage case final msg?)
                    if (msg.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: gap),
                        child: Text(
                          '${context.l10n.settingsRemoteConfigErrorLabel}: '
                          '$msg',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  SizedBox(height: context.responsiveGapM),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: PlatformAdaptive.filledButton(
                          context: context,
                          onPressed: data.isLoading
                              ? null
                              : () => context
                                    .cubit<RemoteConfigCubit>()
                                    .fetchValues(),
                          child: Text(
                            context.l10n.settingsRemoteConfigRetryButton,
                          ),
                        ),
                      ),
                      SizedBox(width: gap),
                      PlatformAdaptive.textButton(
                        context: context,
                        onPressed: data.isLoading
                            ? null
                            : () => context
                                  .cubit<RemoteConfigCubit>()
                                  .clearCache(),
                        child: Text(
                          context.l10n.settingsRemoteConfigClearCacheButton,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
