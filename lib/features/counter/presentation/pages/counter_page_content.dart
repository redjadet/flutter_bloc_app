part of 'counter_page.dart';

class _CounterPageContent extends StatelessWidget {
  const _CounterPageContent({
    required this.title,
    required this.showFlavorBadge,
    required this.confettiController,
    required this.onOpenSettings,
    this.optionalBanner,
  });

  final String title;
  final bool showFlavorBadge;
  final Widget? optionalBanner;
  final ConfettiController confettiController;
  final VoidCallback onOpenSettings;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Scaffold(
          appBar: CounterPageAppBar(
            title: title,
            onOpenSettings: onOpenSettings,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: context.pagePadding,
              child: CommonMaxWidth(
                child: CounterPageBody(
                  theme: theme,
                  l10n: l10n,
                  showFlavorBadge: showFlavorBadge,
                  optionalBanner: optionalBanner,
                ),
              ),
            ),
          ),
          bottomNavigationBar: const CountdownBar(),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(right: context.pageHorizontalPadding),
            child: const CounterActions(),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
        _CounterPageConfettiOverlay(confettiController: confettiController),
      ],
    );
  }
}

class _CounterPageConfettiOverlay extends StatelessWidget {
  const _CounterPageConfettiOverlay({
    required this.confettiController,
  });

  final ConfettiController confettiController;

  @override
  Widget build(final BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          colors:
              Theme.of(context).extension<ConfettiTheme>()?.particleColors ??
              defaultConfettiParticleColors,
        ),
      ),
    );
  }
}
