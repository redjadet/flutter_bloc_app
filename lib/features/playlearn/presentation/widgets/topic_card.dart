import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';

/// Large tappable card for a vocabulary topic (kid-friendly, min 44x48).
/// Uses [CommonCard] with primaryContainer; padding and radius from tokens.
class TopicCard extends StatelessWidget {
  const TopicCard({
    required this.topic,
    required this.displayName,
    required this.onTap,
    super.key,
  });

  final TopicItem topic;
  final String displayName;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(UI.radiusM);
    return CommonCard(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Center(
          child: Text(
            displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
