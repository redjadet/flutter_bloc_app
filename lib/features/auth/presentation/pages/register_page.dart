import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:google_fonts/google_fonts.dart';

/// Register page built from the provided Figma frame specifications.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const double _horizontalPadding = 16;

  @override
  Widget build(final BuildContext context) => const Scaffold(
    backgroundColor: Colors.white,
    appBar: _RegisterAppBar(),
    body: Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 60),
          _RegisterForm(),
        ],
      ),
    ),
  );
}

class _RegisterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _RegisterAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useCupertino =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;
    void onBack() => NavigationUtils.popOrGoHome(context);

    if (useCupertino) {
      return CupertinoNavigationBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onBack,
          child: const Icon(
            CupertinoIcons.left_chevron,
            color: Colors.black,
          ),
        ),
        middle: const SizedBox.shrink(),
      );
    }

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: onBack,
      ),
      title: const SizedBox.shrink(),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  static TextStyle get _titleStyle => GoogleFonts.comfortaa(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 40.14 / 36,
    letterSpacing: -0.54,
    color: Colors.black,
  );

  static TextStyle get _fieldPlaceholderStyle => GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 17.58 / 15,
    color: Colors.black.withValues(alpha: 0.5),
  );

  static TextStyle get _buttonTextStyle => GoogleFonts.roboto(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    height: 15.23 / 13,
    color: Colors.white,
  );

  static const double _componentHeight = 52;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Register', style: _titleStyle),
      const SizedBox(height: 32),
      _OutlinedPlaceholderField(
        height: _componentHeight,
        text: 'Email address',
        style: _fieldPlaceholderStyle,
      ),
      const SizedBox(height: 16),
      _OutlinedPlaceholderField(
        height: _componentHeight,
        text: 'Create password',
        style: _fieldPlaceholderStyle,
      ),
      const SizedBox(height: 16),
      _PrimaryButton(
        height: _componentHeight,
        text: 'NEXT',
        style: _buttonTextStyle,
      ),
    ],
  );
}

class _OutlinedPlaceholderField extends StatelessWidget {
  const _OutlinedPlaceholderField({
    required this.height,
    required this.text,
    required this.style,
  });

  final double height;
  final String text;
  final TextStyle style;

  @override
  Widget build(final BuildContext context) => Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(width: 2),
    ),
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 17),
    child: Text(text, style: style),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.height,
    required this.text,
    required this.style,
  });

  final double height;
  final String text;
  final TextStyle style;

  @override
  Widget build(final BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
