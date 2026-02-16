import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_error_messages.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_form_styles.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_password_field.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_phone_field.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_terms_dialog.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_terms_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<RegisterCubit, RegisterState>(
        builder: (final context, final state) {
          final cubit = context.cubit<RegisterCubit>();
          final l10n = AppLocalizations.of(context);
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final labelStyle = registerLabelStyle(context);
          final fieldTextStyle = registerFieldTextStyle(context);
          final bool isCupertino = PlatformAdaptive.isCupertino(context);

          InputDecoration decorationBuilder({
            required final String hint,
            final String? errorText,
          }) => registerInputDecoration(
            context,
            hint: hint,
            errorText: errorText,
          );

          Future<void> openTermsDialog() async {
            final bool? accepted = await showAdaptiveDialog<bool>(
              context: context,
              builder: (final dialogContext) => const RegisterTermsDialog(),
            );
            cubit
              ..markTermsViewed()
              ..termsAcceptanceChanged(accepted: accepted ?? false);
          }

          Widget buildLabeledField({
            required final String label,
            required final Widget field,
          }) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              SizedBox(height: context.responsiveGapS),
              field,
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.registerTitle, style: registerTitleStyle(context)),
              SizedBox(height: context.responsiveGapL * 2),
              buildLabeledField(
                label: l10n.registerFullNameLabel,
                field: TextFormField(
                  key: const ValueKey('register-full-name-field'),
                  initialValue: state.fullName.value,
                  decoration: decorationBuilder(
                    hint: l10n.registerFullNameHint,
                    errorText: fullNameErrorText(l10n, state.fullNameError),
                  ),
                  style: fieldTextStyle,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.fullNameChanged,
                ),
              ),
              SizedBox(height: context.responsiveGapM),
              buildLabeledField(
                label: l10n.registerEmailLabel,
                field: TextFormField(
                  key: const ValueKey('register-email-field'),
                  initialValue: state.email.value,
                  decoration: decorationBuilder(
                    hint: l10n.registerEmailHint,
                    errorText: emailErrorText(l10n, state.emailError),
                  ),
                  style: fieldTextStyle,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.emailChanged,
                ),
              ),
              SizedBox(height: context.responsiveGapM),
              buildLabeledField(
                label: l10n.registerPhoneLabel,
                field: RegisterPhoneField(
                  state: state,
                  decorationBuilder:
                      ({
                        required final hint,
                        final errorText,
                      }) => decorationBuilder(
                        hint: hint,
                        errorText: errorText,
                      ),
                  hintText: l10n.registerPhoneHint,
                  errorText: phoneErrorText(l10n, state.phoneError),
                  textStyle: fieldTextStyle,
                  onPhoneChanged: cubit.phoneChanged,
                  onCountryChanged: cubit.countrySelected,
                ),
              ),
              SizedBox(height: context.responsiveGapM),
              buildLabeledField(
                label: l10n.registerPasswordLabel,
                field: RegisterPasswordField(
                  key: const ValueKey('register-password-field'),
                  hint: l10n.registerPasswordHint,
                  errorText: passwordErrorText(l10n, state.passwordError),
                  value: state.password.value,
                  onChanged: cubit.passwordChanged,
                  textStyle: fieldTextStyle,
                ),
              ),
              SizedBox(height: context.responsiveGapM),
              buildLabeledField(
                label: l10n.registerConfirmPasswordLabel,
                field: RegisterPasswordField(
                  key: const ValueKey('register-confirm-password-field'),
                  hint: l10n.registerConfirmPasswordHint,
                  errorText: confirmPasswordErrorText(
                    l10n,
                    state.confirmPasswordError,
                  ),
                  value: state.confirmPassword.value,
                  onChanged: cubit.confirmPasswordChanged,
                  textStyle: fieldTextStyle,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => cubit.submit(),
                ),
              ),
              SizedBox(height: context.responsiveGapM),
              RegisterTermsSection(
                accepted: state.acceptedTerms,
                showError: state.termsAcceptanceError,
                onAcceptRequested: openTermsDialog,
                onRevokeAcceptance: () =>
                    cubit.termsAcceptanceChanged(accepted: false),
                prefixText: l10n.registerTermsCheckboxPrefix,
                suffixText: l10n.registerTermsCheckboxSuffix,
                linkLabel: l10n.registerTermsLinkLabel,
                linkStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  decoration: isCupertino ? null : TextDecoration.underline,
                ),
                errorText: l10n.registerTermsError,
                bodyStyle: theme.textTheme.bodyMedium,
                errorStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              SizedBox(height: context.responsiveGapL * 1.5),
              SizedBox(
                width: double.infinity,
                height: isCupertino ? null : 52,
                child: PlatformAdaptive.filledButton(
                  key: const ValueKey('register-submit-button'),
                  context: context,
                  onPressed: cubit.submit,
                  child: Text(l10n.registerSubmitButton),
                ),
              ),
            ],
          );
        },
      );
}
