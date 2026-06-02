part of 'fcm_demo_page.dart';

class _TokenSection extends StatelessWidget {
  const _TokenSection({
    required this.label,
    required this.value,
    required this.l10n,
  });

  final String label;
  final String? value;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final String? tokenValue = value;
    final String display = (tokenValue != null && tokenValue.isNotEmpty)
        ? tokenValue
        : l10n.fcmDemoTokenNotAvailable;
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (tokenValue != null && tokenValue.isNotEmpty)
                PlatformAdaptive.textButton(
                  context: context,
                  onPressed: () => _handleCopyPressed(context, tokenValue),
                  child: Text(l10n.fcmDemoCopyToken),
                ),
            ],
          ),
          SizedBox(height: context.responsiveGapXS),
          SelectableText(
            display,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _handleCopyPressed(final BuildContext context, final String text) {
    unawaited(_copyToken(context, text));
  }

  Future<void> _copyToken(final BuildContext context, final String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ErrorHandling.showSuccessSnackBar(
          context,
          l10n.fcmDemoCopySuccess,
        );
      }
    } on Exception {
      if (context.mounted) {
        ErrorHandling.showErrorSnackBar(
          context,
          l10n.fcmDemoCopyFailure,
        );
      }
    }
  }
}

class _LastMessageSection extends StatelessWidget {
  const _LastMessageSection({
    required this.message,
    required this.l10n,
  });

  final PushMessage? message;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final PushMessage? msg = message;
    final String titleText = msg?.title ?? '';
    final String bodyText = msg?.body ?? '';
    final bool hasTitle = titleText.isNotEmpty;
    final bool hasBody = bodyText.isNotEmpty;
    final bool hasData = msg?.data.isNotEmpty ?? false;
    final bool isEmpty = !hasTitle && !hasBody && !hasData;

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.fcmDemoLastMessageLabel,
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: context.responsiveGapXS),
          if (msg == null)
            Text(
              l10n.fcmDemoLastMessageNone,
              style: theme.textTheme.bodyMedium,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (hasTitle)
                  Text(
                    titleText,
                    style: theme.textTheme.titleSmall,
                  ),
                if (hasBody)
                  Text(
                    bodyText,
                    style: theme.textTheme.bodyMedium,
                  ),
                if (hasData)
                  Padding(
                    padding: EdgeInsets.only(top: context.responsiveGapS),
                    child: Text(
                      msg.data.entries
                          .map((final e) => '${e.key}: ${e.value}')
                          .join(', '),
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                    ),
                  ),
                if (isEmpty)
                  Text(
                    msg.messageId.isNotEmpty
                        ? '${l10n.fcmDemoLastMessageReceived} (id: ${msg.messageId})'
                        : l10n.fcmDemoLastMessageReceived,
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
