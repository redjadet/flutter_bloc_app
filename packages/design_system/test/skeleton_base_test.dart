import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  testWidgets('SkeletonBase renders child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const Scaffold(
          body: SkeletonBase(
            semanticLabel: 'Loading items',
            child: Text('placeholder'),
          ),
        ),
      ),
    );

    expect(find.text('placeholder'), findsOneWidget);
    expect(find.byType(SkeletonBase), findsOneWidget);
  });

  testWidgets('SkeletonBase uses solid effect when animations disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const Scaffold(body: SkeletonBase(child: Text('placeholder'))),
      ),
    );

    expect(find.text('placeholder'), findsOneWidget);
    final Finder skeletonizerFinder = find.descendant(
      of: find.byType(SkeletonBase),
      matching: find.byWidgetPredicate((widget) => widget is Skeletonizer),
    );
    expect(skeletonizerFinder, findsOneWidget);
    final Skeletonizer skeletonizer = tester.widget(skeletonizerFinder);
    expect(skeletonizer.effect, isA<SolidColorEffect>());
    expect(skeletonizer.enableSwitchAnimation, isFalse);
  });

  test('loadingEffect returns shimmer unless reduce motion', () {
    final ColorScheme colors = ColorScheme.fromSeed(seedColor: Colors.blue);
    expect(
      SkeletonBase.loadingEffect(colors, reduceMotion: false),
      isA<ShimmerEffect>(),
    );
    expect(
      SkeletonBase.loadingEffect(colors, reduceMotion: true),
      isA<SolidColorEffect>(),
    );
  });
}
