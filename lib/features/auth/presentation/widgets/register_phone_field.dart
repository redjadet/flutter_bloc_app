import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_country_option.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_country_picker.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

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
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalGapM,
          vertical: context.responsiveGapM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            context.responsiveCardRadius * 0.5,
          ),
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
          SizedBox(width: context.responsiveHorizontalGapS),
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
