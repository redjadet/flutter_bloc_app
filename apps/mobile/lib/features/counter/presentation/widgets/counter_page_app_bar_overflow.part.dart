part of 'counter_page_app_bar.dart';

final List<OverflowItem> _counterPageOverflowItems = <OverflowItem>[
  OverflowItem(
    action: OverflowAction.caseStudyDemo,
    routeName: AppRoutes.caseStudyDemo,
    labelBuilder: (final l10n) => l10n.openCaseStudyDemoTooltip,
  ),
  OverflowItem(
    action: OverflowAction.charts,
    routeName: AppRoutes.charts,
    labelBuilder: (final l10n) => l10n.openChartsTooltip,
  ),
  OverflowItem(
    action: OverflowAction.graphql,
    routeName: AppRoutes.graphql,
    labelBuilder: (final l10n) => l10n.openGraphqlTooltip,
  ),
  OverflowItem(
    action: OverflowAction.chat,
    routeName: AppRoutes.chat,
    labelBuilder: (final l10n) => l10n.openChatTooltip,
  ),
  OverflowItem(
    action: OverflowAction.genuiDemo,
    routeName: AppRoutes.genuiDemo,
    labelBuilder: (final l10n) => l10n.openGenuiDemoTooltip,
  ),
  OverflowItem(
    action: OverflowAction.onlineTherapyDemo,
    routeName: AppRoutes.onlineTherapyDemo,
    labelBuilder: (_) => 'Open Online Therapy Demo',
  ),
  OverflowItem(
    action: OverflowAction.googleMaps,
    routeName: AppRoutes.googleMaps,
    labelBuilder: (final l10n) => l10n.openGoogleMapsTooltip,
  ),
  OverflowItem(
    action: OverflowAction.whiteboard,
    routeName: AppRoutes.whiteboard,
    labelBuilder: (final l10n) => l10n.openWhiteboardTooltip,
  ),
  OverflowItem(
    action: OverflowAction.markdownEditor,
    routeName: AppRoutes.markdownEditor,
    labelBuilder: (final l10n) => l10n.openMarkdownEditorTooltip,
  ),
  OverflowItem(
    action: OverflowAction.todo,
    routeName: AppRoutes.todoList,
    labelBuilder: (final l10n) => l10n.openTodoTooltip,
  ),
  OverflowItem(
    action: OverflowAction.playlearn,
    routeName: AppRoutes.playlearn,
    labelBuilder: (final l10n) => l10n.openPlaylearnTooltip,
  ),
  OverflowItem(
    action: OverflowAction.igamingDemo,
    routeName: AppRoutes.igamingDemo,
    labelBuilder: (final l10n) => l10n.openIgamingDemoTooltip,
  ),
  OverflowItem(
    action: OverflowAction.iotDemo,
    routeName: AppRoutes.iotDemo,
    labelBuilder: (final l10n) => l10n.openIotDemoTooltip,
  ),
  OverflowItem(
    action: OverflowAction.realtimeMarket,
    routeName: AppRoutes.realtimeMarket,
    labelBuilder: (final l10n) => l10n.openRealtimeMarketTooltip,
  ),
  OverflowItem(
    action: OverflowAction.certificatePinningDemo,
    routeName: AppRoutes.certificatePinningDemo,
    labelBuilder: (final l10n) => l10n.openCertificatePinningDemoTooltip,
  ),
];

extension _CounterPageAppBarUi on CounterPageAppBar {
  AppBar buildMaterialAppBar(
    final BuildContext context,
    final ThemeData theme,
    final AppLocalizations l10n,
  ) => AppBar(
    backgroundColor: theme.colorScheme.inversePrimary,
    title: Text(
      title,
      style: theme.textTheme.titleLarge,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    actions: [
      IconButton(
        tooltip: l10n.openCalculatorTooltip,
        onPressed: () => context.pushNamed(AppRoutes.calculator),
        icon: const Icon(Icons.payments_outlined),
      ),
      IconButton(
        tooltip: l10n.openExampleTooltip,
        onPressed: () => context.pushNamed(AppRoutes.example),
        icon: const Icon(Icons.explore),
      ),
      IconButton(
        tooltip: l10n.openRealtimeMarketTooltip,
        onPressed: () => context.pushNamed(AppRoutes.realtimeMarket),
        icon: const Icon(Icons.show_chart),
      ),
      IconButton(
        tooltip: l10n.openCaseStudyDemoTooltip,
        onPressed: () => context.pushNamed(AppRoutes.caseStudyDemo),
        icon: const Icon(Icons.ondemand_video_outlined),
      ),
      IconButton(
        tooltip: l10n.openSettingsTooltip,
        onPressed: onOpenSettings,
        icon: const Icon(Icons.settings),
      ),
      PopupMenuButton<OverflowAction>(
        tooltip: l10n.moreTooltip,
        onSelected: (final action) => handleOverflowSelection(context, action),
        itemBuilder: (final context) => _counterPageOverflowItems
            .map(
              (final item) => PopupMenuItem<OverflowAction>(
                value: item.action,
                child: Text(item.labelBuilder(l10n)),
              ),
            )
            .toList(),
      ),
    ],
  );

  CupertinoNavigationBar buildCupertinoAppBar(
    final BuildContext context,
    final ThemeData theme,
    final AppLocalizations l10n,
  ) {
    final colorScheme = theme.colorScheme;
    final TextStyle titleStyle =
        theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
        ) ??
        TextStyle(
          color: colorScheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        );

    return CupertinoNavigationBar(
      backgroundColor: colorScheme.surface.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.98 : 1,
      ),
      middle: DefaultTextStyle(style: titleStyle, child: Text(title)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoIconButton(
            icon: CupertinoIcons.money_dollar,
            onPressed: () => context.pushNamed(AppRoutes.calculator),
            tooltip: l10n.openCalculatorTooltip,
          ),
          CupertinoIconButton(
            icon: CupertinoIcons.compass,
            onPressed: () => context.pushNamed(AppRoutes.example),
            tooltip: l10n.openExampleTooltip,
          ),
          CupertinoIconButton(
            icon: CupertinoIcons.chart_bar,
            onPressed: () => context.pushNamed(AppRoutes.realtimeMarket),
            tooltip: l10n.openRealtimeMarketTooltip,
          ),
          CupertinoIconButton(
            icon: CupertinoIcons.videocam,
            onPressed: () => context.pushNamed(AppRoutes.caseStudyDemo),
            tooltip: l10n.openCaseStudyDemoTooltip,
          ),
          CupertinoIconButton(
            icon: CupertinoIcons.settings,
            onPressed: onOpenSettings,
            tooltip: l10n.openSettingsTooltip,
          ),
          CupertinoIconButton(
            icon: CupertinoIcons.ellipsis_vertical,
            onPressed: () => showOverflowSheet(context, l10n),
            tooltip: l10n.moreTooltip,
          ),
        ],
      ),
    );
  }

  Future<void> showOverflowSheet(
    final BuildContext context,
    final AppLocalizations l10n,
  ) async {
    final BuildContext parentContext = context;
    await showCupertinoModalPopup<void>(
      context: parentContext,
      builder: (final sheetContext) => CupertinoActionSheet(
        title: Text(l10n.moreTooltip),
        actions: _counterPageOverflowItems
            .map(
              (final item) => CupertinoActionSheetAction(
                onPressed: () {
                  NavigationUtils.maybePop(sheetContext);
                  navigateToOverflowItem(parentContext, item);
                },
                child: Text(item.labelBuilder(l10n)),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => NavigationUtils.maybePop(sheetContext),
          child: Text(l10n.cancelButtonLabel),
        ),
      ),
    );
  }

  void handleOverflowSelection(
    final BuildContext context,
    final OverflowAction action,
  ) {
    if (_counterPageOverflowItems.isEmpty) {
      return;
    }
    final OverflowItem item = _counterPageOverflowItems.firstWhere(
      (final entry) => entry.action == action,
      orElse: () => _counterPageOverflowItems.first,
    );
    navigateToOverflowItem(context, item);
  }

  void navigateToOverflowItem(
    final BuildContext context,
    final OverflowItem item,
  ) {
    if (!context.mounted) {
      ContextUtils.logNotMounted(
        'CounterPageAppBar._navigateToOverflowItem',
      );
      return;
    }
    unawaited(context.pushNamed(item.routeName));
  }
}
