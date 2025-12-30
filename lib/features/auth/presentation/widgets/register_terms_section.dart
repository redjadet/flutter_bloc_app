import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class RegisterTermsSection extends StatelessWidget {
  const RegisterTermsSection({
    required this.accepted,
    required this.showError,
    required this.onAcceptRequested,
    required this.onRevokeAcceptance,
    required this.prefixText,
    required this.suffixText,
    required this.linkLabel,
    required this.linkStyle,
    required this.errorText,
    required this.bodyStyle,
    required this.errorStyle,
    super.key,
  });

  final bool accepted;
  final bool showError;
  final Future<void> Function() onAcceptRequested;
  final VoidCallback onRevokeAcceptance;
  final String prefixText;
  final String suffixText;
  final String linkLabel;
  final TextStyle? linkStyle;
  final String errorText;
  final TextStyle? bodyStyle;
  final TextStyle? errorStyle;

  @override
  Widget build(final BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Checkbox.adaptive(
        key: const ValueKey('register-terms-checkbox'),
        value: accepted,
        onChanged: (final bool? checked) async {
          if (checked ?? false) {
            await onAcceptRequested();
          } else {
            onRevokeAcceptance();
          }
        },
      ),
      SizedBox(width: context.responsiveHorizontalGapS),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(prefixText, style: bodyStyle),
                KeyedSubtree(
                  key: const ValueKey('register-terms-link'),
                  child: PlatformAdaptive.textButton(
                    context: context,
                    onPressed: onAcceptRequested,
                    materialStyle: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      linkLabel,
                      style: linkStyle,
                    ),
                  ),
                ),
                Text(suffixText, style: bodyStyle),
              ],
            ),
            if (showError)
              Padding(
                padding: EdgeInsets.only(top: context.responsiveGapXS),
                child: Text(
                  errorText,
                  style: errorStyle,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
