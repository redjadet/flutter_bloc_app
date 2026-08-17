import 'package:design_system/responsive.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_button_styles.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('ProfileButtonStyles', () {
    testWidgets('profileOutlinedButtonStyle creates button style', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => buildAppMixScope(
              context,
              child: ResponsiveScope(
                child: Scaffold(
                  body: Builder(
                    builder: (innerContext) {
                      final style = profileOutlinedButtonStyle(
                        innerContext,
                        backgroundColor: Colors.blue,
                      );
                      expect(style, isNotNull);
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('profileButtonTextStyle creates text style with theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => buildAppMixScope(
              context,
              child: ResponsiveScope(
                child: Scaffold(
                  body: Builder(
                    builder: (innerContext) {
                      final style = profileButtonTextStyle(
                        innerContext,
                        color: Colors.red,
                        fontSize: 16.0,
                      );
                      expect(style, isNotNull);
                      expect(style.color, Colors.red);
                      expect(style.fontSize, 16.0);
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'profileButtonTextStyle falls back when theme textTheme is null',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(textTheme: const TextTheme()),
            home: Builder(
              builder: (context) => buildAppMixScope(
                context,
                child: ResponsiveScope(
                  child: Scaffold(
                    body: Builder(
                      builder: (innerContext) {
                        final style = profileButtonTextStyle(
                          innerContext,
                          color: Colors.blue,
                          fontSize: 14.0,
                        );
                        expect(style, isNotNull);
                        expect(style.color, Colors.blue);
                        expect(style.fontSize, 14.0);
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );
  });
}
