import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CounterLastChangedText extends StatelessWidget {
  const CounterLastChangedText({
    super.key,
    required this.lastChanged,
    required this.l10n,
    required this.textTheme,
  });

  final DateTime? lastChanged;
  final AppLocalizations l10n;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final formatted = lastChanged == null
        ? '-'
        : DateFormat.yMd(locale).add_jm().format(lastChanged!);
    final double fontSize = (textTheme.bodySmall?.fontSize ?? 11).sp;
    return Text(
      '${l10n.lastChangedLabel} $formatted',
      style: textTheme.bodySmall?.copyWith(fontSize: fontSize),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
