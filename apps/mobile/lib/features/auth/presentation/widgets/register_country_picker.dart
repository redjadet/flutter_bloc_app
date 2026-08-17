import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_country_option.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mix/mix.dart';

Future<CountryOption?> showCountryPicker({
  required BuildContext context,
  required CountryOption selected,
}) async {
  final l10n = AppLocalizations.of(context);
  final bool isCupertino = PlatformAdaptive.isCupertino(context);

  if (isCupertino) {
    return showCupertinoModalPopup<CountryOption>(
      context: context,
      builder: (popupContext) => CupertinoActionSheet(
        title: Text(l10n.registerCountryPickerTitle),
        actions: kSupportedCountries
            .map(
              (country) => CupertinoActionSheetAction(
                key: ValueKey<String>('country-${country.code}'),
                isDefaultAction: country == selected,
                onPressed: () =>
                    NavigationUtils.maybePop(popupContext, result: country),
                child: _CountryPickerRow(option: country),
              ),
            )
            .toList(growable: false),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => NavigationUtils.maybePop(popupContext),
          child: Text(l10n.cancelButtonLabel),
        ),
      ),
    );
  }

  return showModalBottomSheet<CountryOption>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final titleStyle = theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      );
      return SafeArea(
        child: Box(
          style: AppStyles.dialogContent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: context.responsiveGapM),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.registerCountryPickerTitle,
                    style: titleStyle,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: kSupportedCountries.length,
                  itemBuilder: (context, index) {
                    final country = kSupportedCountries[index];
                    final bool isSelected = country == selected;
                    return ListTile(
                      key: ValueKey<String>('country-${country.code}'),
                      leading: Text(
                        country.flagEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(country.name),
                      subtitle: Text(country.dialCode),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      onTap: () => NavigationUtils.maybePop(
                        sheetContext,
                        result: country,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CountryPickerRow extends StatelessWidget {
  const _CountryPickerRow({required this.option});

  final CountryOption option;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        option.flagEmoji,
        style: const TextStyle(fontSize: 24),
      ),
      SizedBox(width: context.responsiveHorizontalGapS),
      Expanded(
        child: Text(
          '${option.name} (${option.dialCode})',
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}
