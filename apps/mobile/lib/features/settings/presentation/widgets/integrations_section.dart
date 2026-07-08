import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
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
          trailing: SizedBox.square(
            dimension: 24,
            child: Center(
              child: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          onTap: () => context.push(AppRoutes.supabaseAuthPath),
        ),
      ),
    );
  }
}
