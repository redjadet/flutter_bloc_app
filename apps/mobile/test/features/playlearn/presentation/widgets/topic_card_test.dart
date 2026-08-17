import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/widgets/topic_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders display name and handles tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: TopicCard(
            topic: const TopicItem(id: 'animals', nameL10nKey: 'k'),
            displayName: 'Animals',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Animals'), findsOneWidget);
    await tester.tap(find.text('Animals'));
    expect(tapped, isTrue);
  });
}
