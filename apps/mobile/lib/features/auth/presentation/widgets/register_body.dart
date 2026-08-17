import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_form.dart';
import 'package:material_ui/material_ui.dart';

class ResponsiveRegisterBody extends StatelessWidget {
  const ResponsiveRegisterBody({super.key});

  static const double _horizontalPadding = 20;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final bool isWide = constraints.maxWidth >= 720;
      final double maxContentWidth = isWide ? 520 : constraints.maxWidth;

      return CommonMaxWidth(
        maxWidth: maxContentWidth,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? _horizontalPadding * 1.5 : _horizontalPadding,
            vertical: 32,
          ),
          child: const RegisterForm(),
        ),
      );
    },
  );
}
