import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Large tappable card for a vocabulary topic (kid-friendly, min 44x48).
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
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(context.responsiveGapL),
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
      ),
    );
  }
}
