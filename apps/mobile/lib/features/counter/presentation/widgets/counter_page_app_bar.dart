import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_page_app_bar_helpers.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:go_router/go_router.dart';

part 'counter_page_app_bar_overflow.part.dart';

class CounterPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CounterPageAppBar({
    required this.title,
    required this.onOpenSettings,
    super.key,
  });

  final String title;
  final VoidCallback onOpenSettings;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final bool useCupertino = _isCupertinoPlatform(theme.platform);
    return useCupertino
        ? buildCupertinoAppBar(context, theme, l10n)
        : buildMaterialAppBar(context, theme, l10n);
  }

  bool _isCupertinoPlatform(final TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}
