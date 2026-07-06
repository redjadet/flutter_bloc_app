import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class NativePlatformShowcaseLessonCards extends StatelessWidget {
  const NativePlatformShowcaseLessonCards({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final lessons = <({String title, String body})>[
      (
        title: l10n.nativePlatformShowcaseLesson1Title,
        body: l10n.nativePlatformShowcaseLesson1Body,
      ),
      (
        title: l10n.nativePlatformShowcaseLesson2Title,
        body: l10n.nativePlatformShowcaseLesson2Body,
      ),
      (
        title: l10n.nativePlatformShowcaseLesson3Title,
        body: l10n.nativePlatformShowcaseLesson3Body,
      ),
      (
        title: l10n.nativePlatformShowcaseLesson4Title,
        body: l10n.nativePlatformShowcaseLesson4Body,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(lessons.length, (index) {
        final lesson = lessons[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == lessons.length - 1 ? 0 : context.responsiveGapS,
          ),
          child: KeyedSubtree(
            key: ValueKey<String>('native-platform-showcase-lesson-$index'),
            child: CommonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: context.responsiveGapXS),
                  Text(
                    lesson.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
