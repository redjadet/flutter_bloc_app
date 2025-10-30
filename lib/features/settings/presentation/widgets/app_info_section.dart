import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/app_info_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.appInfoSectionTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapS),
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UI.cardPadH,
              vertical: UI.cardPadV,
            ),
            child: BlocBuilder<AppInfoCubit, AppInfoState>(
              builder: (final context, final state) {
                if (state.status.isSuccess && state.info != null) {
                  return _InfoDetails(infoState: state);
                }
                if (state.status.isError) {
                  return _ErrorContent(error: state.errorMessage);
                }
                return const _LoadingContent();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoDetails extends StatelessWidget {
  const _InfoDetails({required this.infoState});

  final AppInfoState infoState;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final TextStyle? labelStyle = Theme.of(context).textTheme.bodyMedium;
    final TextStyle? valueStyle = Theme.of(context).textTheme.bodyLarge;
    final AppInfo info = infoState.info!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _InfoRow(
          label: l10n.appInfoVersionLabel,
          value: info.version,
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        SizedBox(height: UI.gapS),
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
      SizedBox(height: UI.gapXS),
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
        if (error != null && error!.trim().isNotEmpty) ...<Widget>[
          SizedBox(height: UI.gapXS),
          Text(error!, style: theme.textTheme.bodySmall),
        ],
        SizedBox(height: UI.gapS),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.read<AppInfoCubit>().load(),
            child: Text(l10n.appInfoRetryButtonLabel),
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
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        SizedBox(
          width: UI.iconL,
          height: UI.iconL,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(width: UI.horizontalGapM),
        Expanded(
          child: Text(
            l10n.appInfoLoadingLabel,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
