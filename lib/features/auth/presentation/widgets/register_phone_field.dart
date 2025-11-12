import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class RegisterPhoneField extends StatelessWidget {
  const RegisterPhoneField({
    required this.state,
    required this.decorationBuilder,
    required this.hintText,
    required this.errorText,
    required this.textStyle,
    required this.onPhoneChanged,
    required this.onCountryChanged,
    super.key,
  });

  final RegisterState state;
  final InputDecoration Function({
    required String hint,
    String? errorText,
  })
  decorationBuilder;
  final String hintText;
  final String? errorText;
  final TextStyle textStyle;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<CountryOption> onCountryChanged;

  @override
  Widget build(final BuildContext context) => Row(
    children: [
      _CountryChip(
        country: state.selectedCountry,
        onPressed: () async {
          final CountryOption? selection = await showCountryPicker(
            context: context,
            selected: state.selectedCountry,
          );
          if (selection != null) {
            onCountryChanged(selection);
          }
        },
      ),
      SizedBox(width: context.responsiveHorizontalGapM),
      Expanded(
        child: TextFormField(
          key: const ValueKey('register-phone-field'),
          initialValue: state.phoneNumber.value,
          decoration: decorationBuilder(
            hint: hintText,
            errorText: errorText,
          ),
          style: textStyle,
          cursorColor: Theme.of(context).colorScheme.primary,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onChanged: onPhoneChanged,
        ),
      ),
    ],
  );
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({
    required this.country,
    required this.onPressed,
  });

  final CountryOption country;
  final Future<void> Function() onPressed;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return OutlinedButton(
      key: const ValueKey('register-country-selector'),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            country.flagEmoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            country.dialCode,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

Future<CountryOption?> showCountryPicker({
  required final BuildContext context,
  required final CountryOption selected,
}) async {
  final l10n = AppLocalizations.of(context);
  final bool isCupertino = PlatformAdaptive.isCupertino(context);

  if (isCupertino) {
    return showCupertinoModalPopup<CountryOption>(
      context: context,
      builder: (final popupContext) => CupertinoActionSheet(
        title: Text(l10n.registerCountryPickerTitle),
        actions: kSupportedCountries
            .map(
              (final country) => CupertinoActionSheetAction(
                isDefaultAction: country == selected,
                onPressed: () => Navigator.of(popupContext).pop(country),
                child: _CountryPickerRow(option: country),
              ),
            )
            .toList(growable: false),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(popupContext).pop(),
          child: Text(l10n.cancelButtonLabel),
        ),
      ),
    );
  }

  return showModalBottomSheet<CountryOption>(
    context: context,
    useSafeArea: true,
    builder: (final sheetContext) {
      final theme = Theme.of(sheetContext);
      final titleStyle = theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      );
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.registerCountryPickerTitle,
                  style: titleStyle,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: kSupportedCountries.length,
                itemBuilder: (final context, final index) {
                  final country = kSupportedCountries[index];
                  final bool isSelected = country == selected;
                  return ListTile(
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
                    onTap: () => Navigator.of(sheetContext).pop(country),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _CountryPickerRow extends StatelessWidget {
  const _CountryPickerRow({required this.option});

  final CountryOption option;

  @override
  Widget build(final BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        option.flagEmoji,
        style: const TextStyle(fontSize: 24),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '${option.name} (${option.dialCode})',
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}
