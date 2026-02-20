import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/app_info_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info_section.freezed.dart';

@freezed
abstract class _AppInfoViewData with _$AppInfoViewData {
  const factory _AppInfoViewData({
    required final bool showSuccess,
    required final bool showError,
    required final AppInfo? info,
    required final String? errorMessage,
  }) = __AppInfoViewData;
}

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return SettingsSection(
      title: l10n.appInfoSectionTitle,
      child: CommonCard(
        child:
            TypeSafeBlocSelector<AppInfoCubit, AppInfoState, _AppInfoViewData>(
              selector: (final state) => _AppInfoViewData(
                showSuccess: state.status.isSuccess && state.info != null,
                showError: state.status.isError,
                info: state.info,
                errorMessage: state.errorMessage,
              ),
              builder: (final context, final data) {
                if ((data.showSuccess, data.info) case (true, final info?)) {
                  return _InfoDetails(info: info);
                }
                if (data.showError) {
                  return _ErrorContent(error: data.errorMessage);
                }
                return const _LoadingContent();
              },
            ),
      ),
    );
  }
}

class _InfoDetails extends StatelessWidget {
  const _InfoDetails({required this.info});

  final AppInfo info;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final TextStyle? labelStyle = Theme.of(context).textTheme.bodyMedium;
    final TextStyle? valueStyle = Theme.of(context).textTheme.bodyLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _InfoRow(
          label: l10n.appInfoVersionLabel,
          value: info.version,
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        SizedBox(height: context.responsiveGapS),
        _InfoRow(
          label: l10n.appInfoBuildNumberLabel,
          value: info.buildNumber,
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(label, style: labelStyle),
      SizedBox(height: context.responsiveGapXS),
      SelectableText(value, style: valueStyle),
    ],
  );
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({this.error});

  final String? error;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.appInfoLoadErrorLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        if (error case final e?) ...<Widget>[
          if (e.trim().isNotEmpty) ...[
            SizedBox(height: context.responsiveGapXS),
            Text(e, style: theme.textTheme.bodySmall),
          ],
        ],
        SizedBox(height: context.responsiveGapS),
        Align(
          alignment: Alignment.centerLeft,
          child: PlatformAdaptive.dialogAction(
            context: context,
            label: l10n.appInfoRetryButtonLabel,
            onPressed: () => context.cubit<AppInfoCubit>().load(),
          ),
        ),
      ],
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        SizedBox(
          width: context.responsiveIconSize,
          height: context.responsiveIconSize,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: context.responsiveHorizontalGapM),
        Expanded(
          child: Text(
            l10n.appInfoLoadingLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
