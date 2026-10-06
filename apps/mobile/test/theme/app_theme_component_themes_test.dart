import 'package:flutter_bloc_app/app/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppTheme component themes', () {
    test('light theme sets dense list tiles and floating snackbars', () {
      final ThemeData theme = AppTheme.lightTheme();

      expect(theme.listTileTheme.dense, isTrue);
      expect(theme.listTileTheme.titleTextStyle?.fontWeight, FontWeight.w600);
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.iconButtonTheme.style, isNotNull);
      expect(theme.progressIndicatorTheme.color, theme.colorScheme.secondary);
    });

    test('dark theme mirrors component themes', () {
      final ThemeData theme = AppTheme.darkTheme();

      expect(theme.listTileTheme.dense, isTrue);
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
    });
  });
}
