import 'package:material_ui/material_ui.dart';

class LoggedOutBackgroundLayer extends StatelessWidget {
  const LoggedOutBackgroundLayer({
    required this.height,
    super.key,
  });

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: height,
    child: _BackgroundImage(height: height),
  );
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/figma/Logged_out_0-2/Rectangle_0-42.png',
    height: height,
    fit: BoxFit.fill,
    errorBuilder: (context, error, stackTrace) => Container(
      height: height,
      color: Theme.of(context).colorScheme.surface,
    ),
  );
}
