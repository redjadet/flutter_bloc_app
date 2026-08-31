import 'package:material_ui/material_ui.dart';

class SocialFeedLoadingView extends StatelessWidget {
  const SocialFeedLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        key: ValueKey('social-feed-loading'),
      ),
    );
  }
}
