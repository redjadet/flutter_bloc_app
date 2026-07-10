import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart';

void main() {
  testWidgets('shows unavailable placeholder off mobile', (final tester) async {
    await tester.pumpWidget(
      wrapWithProviders(
        child: const Scaffold(
          body: NativePlatformShowcasePlatformViewSection(
            platformOverride: TargetPlatform.macOS,
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey<String>('native-platform-showcase-platform-view'),
      ),
      findsOneWidget,
    );
    expect(find.byType(UiKitView), findsNothing);
    expect(find.byType(AndroidView), findsNothing);
  });
}
