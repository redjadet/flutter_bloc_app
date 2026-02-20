import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CounterLastChangedText extends StatelessWidget {
  const CounterLastChangedText({
    required this.lastChanged,
    required this.l10n,
    required this.textTheme,
    super.key,
  });

  final DateTime? lastChanged;
  final AppLocalizations l10n;
  final TextTheme textTheme;

  @override
  Widget build(final BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final formatted = switch (lastChanged) {
      final d? => DateFormat.yMd(locale).add_jm().format(d),
      _ => '-',
    };
    final double fontSize = (textTheme.bodySmall?.fontSize ?? 11).sp;
    return Text(
      '${l10n.lastChangedLabel} $formatted',
      style: textTheme.bodySmall?.copyWith(fontSize: fontSize),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
