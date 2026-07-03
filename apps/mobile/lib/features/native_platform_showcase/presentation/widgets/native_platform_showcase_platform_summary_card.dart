import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_adaptive.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_showcase_l10n_extensions.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class NativePlatformShowcasePlatformSummaryCard extends StatelessWidget {
  const NativePlatformShowcasePlatformSummaryCard({
    required this.platform,
    super.key,
  });

  final AppPlatformKind platform;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isCupertino = NativePlatformShowcaseAdaptive.isCupertino(
      context,
    );
    final String uiFamilyLabel = isCupertino
        ? l10n.nativePlatformShowcaseUiCupertino
        : l10n.nativePlatformShowcaseUiMaterial;

    return KeyedSubtree(
      key: const ValueKey<String>('native-platform-showcase-summary'),
      child: NativePlatformShowcaseAdaptive.summarySection(
        context: context,
        rows: <({String label, String value})>[
          (
            label: l10n.nativePlatformShowcaseRuntimePlatformLabel,
            value: platform.label(l10n),
          ),
          (
            label: l10n.nativePlatformShowcaseUiFamilyLabel,
            value: uiFamilyLabel,
          ),
        ],
      ),
    );
  }
}
