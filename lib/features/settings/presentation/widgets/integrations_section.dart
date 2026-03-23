import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/settings_section.dart';
import 'package:go_router/go_router.dart';

/// Settings section with links to integration pages (e.g. Supabase Auth).
class IntegrationsSection extends StatelessWidget {
  const IntegrationsSection({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SettingsSection(
      title: l10n.settingsIntegrationsSection,
      child: CommonCard(
        child: ListTile(
          title: Text(l10n.settingsSupabaseAuth),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: context.responsiveIconSize * 0.8,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onTap: () => context.push(AppRoutes.supabaseAuthPath),
        ),
      ),
    );
  }
}
