part of 'platform_adaptive_sheets.dart';

class _MaterialPickerSheetContent<T> extends StatelessWidget {
  const _MaterialPickerSheetContent({
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.itemKey,
    this.title,
    this.itemBuilder,
  });

  final List<T> items;
  final T selectedItem;
  final String Function(T) itemLabel;
  final Object Function(T item)? itemKey;
  final String? title;
  final Widget Function(BuildContext, T)? itemBuilder;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Box(
        style: AppStyles.dialogContent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (title case final resolvedTitle?)
              Padding(
                padding: EdgeInsets.only(bottom: context.responsiveGapM),
                child: Text(
                  resolvedTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (final itemContext, final index) {
                  final T item = items[index];
                  final Object? keyValue = itemKey?.call(item) ?? item;
                  return _MaterialPickerItemTile<T>(
                    key: ValueKey<Object?>(keyValue),
                    item: item,
                    isSelected: item == selectedItem,
                    itemLabel: itemLabel,
                    itemBuilder: itemBuilder,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialPickerItemTile<T> extends StatelessWidget {
  const _MaterialPickerItemTile({
    required this.item,
    required this.isSelected,
    required this.itemLabel,
    this.itemBuilder,
    super.key,
  });

  final T item;
  final bool isSelected;
  final String Function(T) itemLabel;
  final Widget Function(BuildContext, T)? itemBuilder;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      title: switch (itemBuilder) {
        final Widget Function(BuildContext, T) builder => builder(
          context,
          item,
        ),
        _ => Text(itemLabel(item)),
      },
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: () => NavigationUtils.maybePop(context, result: item),
    );
  }
}

/// Stateful widget that owns `FixedExtentScrollController` for `CupertinoPicker`.
///
/// Controllers must be created in initState and disposed in dispose per
/// Flutter ownership rules.
class _CupertinoPickerSheetContent<T> extends StatefulWidget {
  const _CupertinoPickerSheetContent({
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.onDone,
    required this.onCancel,
    required this.itemKey,
    this.title,
    this.itemBuilder,
  });

  final List<T> items;
  final T selectedItem;
  final String? title;
  final String Function(T) itemLabel;
  final Object Function(T item)? itemKey;
  final Widget Function(BuildContext, T)? itemBuilder;
  final void Function(T result) onDone;
  final VoidCallback onCancel;

  @override
  State<_CupertinoPickerSheetContent<T>> createState() =>
      _CupertinoPickerSheetContentState<T>();
}

class _CupertinoPickerSheetContentState<T>
    extends State<_CupertinoPickerSheetContent<T>> {
  late final FixedExtentScrollController _scrollController;
  late T _currentSelection;

  @override
  void initState() {
    super.initState();
    final int selectedIndex = widget.items.indexOf(widget.selectedItem);
    _scrollController = FixedExtentScrollController(
      initialItem: selectedIndex >= 0 ? selectedIndex : 0,
    );
    _currentSelection = widget.selectedItem;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 6),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (widget.title case final t?)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            Expanded(
              child: CupertinoPicker(
                scrollController: _scrollController,
                itemExtent: 32,
                onSelectedItemChanged: (final index) {
                  if (index >= 0 && index < widget.items.length) {
                    setState(() {
                      _currentSelection = widget.items[index];
                    });
                  }
                },
                children: widget.items.map(
                  (final item) {
                    final Object? keyValue = widget.itemKey?.call(item) ?? item;
                    return KeyedSubtree(
                      key: ValueKey<Object?>(keyValue),
                      child: Center(
                        child: switch (widget.itemBuilder) {
                          final fn? => fn(context, item),
                          _ => Text(widget.itemLabel(item)),
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            ResponsiveActionOverflowBar(
              spacing: 8,
              children: <Widget>[
                CupertinoButton(
                  onPressed: widget.onCancel,
                  child: Text(context.l10n.cancelButtonLabel),
                ),
                CupertinoButton(
                  onPressed: () => widget.onDone(_currentSelection),
                  child: Text(context.l10n.doneButtonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
