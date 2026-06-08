import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_adaptive.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_showcase_l10n_extensions.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class NativePlatformShowcaseCapabilityList extends StatelessWidget {
  const NativePlatformShowcaseCapabilityList({
    required this.capabilities,
    super.key,
  });

  final List<NativeCapability> capabilities;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: capabilities
          .map((capability) {
            final kind = capability.kind;
            return KeyedSubtree(
              key: ValueKey<String>(
                'native-platform-showcase-capability-${kind.name}',
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: context.responsiveGapXS),
                child: NativePlatformShowcaseAdaptive.capabilityTile(
                  context: context,
                  leading: Icon(
                    NativePlatformShowcaseAdaptive.capabilityIcon(kind),
                  ),
                  title: Text(
                    kind.title(l10n),
                    style: theme.textTheme.titleSmall,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(kind.summary(l10n)),
                      SizedBox(height: context.responsiveGapXS),
                      Text(
                        capability.platformDetail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
