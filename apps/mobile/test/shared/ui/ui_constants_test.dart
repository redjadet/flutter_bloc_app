import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UI', () {
    test('scaleWidth returns value when ScreenUtil not ready', () {
      UI.markScreenUtilUnready();
      expect(UI.scaleWidth(100), 100);
    });

    test('scaleHeight returns value when ScreenUtil not ready', () {
      UI.markScreenUtilUnready();
      expect(UI.scaleHeight(100), 100);
    });

    test('scaleRadius returns value when ScreenUtil not ready', () {
      UI.markScreenUtilUnready();
      expect(UI.scaleRadius(100), 100);
    });

    test('scaleFont returns value when ScreenUtil not ready', () {
      UI.markScreenUtilUnready();
      expect(UI.scaleFont(100), 100);
    });

    test('scaleFontMax returns value when ScreenUtil not ready', () {
      UI.markScreenUtilUnready();
      expect(UI.scaleFontMax(100), 100);
    });

    test('isScreenUtilReady returns false when not ready', () {
      UI.markScreenUtilUnready();
      expect(UI.isScreenUtilReady, isFalse);
    });

    test('markScreenUtilReady sets ready flag', () {
      UI.markScreenUtilReady();
      expect(UI.isScreenUtilReady, isTrue);
    });

    test('markScreenUtilUnready clears ready flag', () {
      UI.markScreenUtilReady();
      UI.markScreenUtilUnready();
      expect(UI.isScreenUtilReady, isFalse);
    });

    test('gap getters return scaled values', () {
      UI.markScreenUtilUnready();
      expect(UI.gapXS, 6);
      expect(UI.gapS, 8);
      expect(UI.gapM, 12);
      expect(UI.gapL, 16);
    });

    test('horizontalGap getters return scaled values', () {
      UI.markScreenUtilUnready();
      expect(UI.horizontalGapXS, 6);
      expect(UI.horizontalGapS, 8);
      expect(UI.horizontalGapM, 10);
      expect(UI.horizontalGapL, 16);
    });

    test('cardPad getters return scaled values', () {
      UI.markScreenUtilUnready();
      expect(UI.cardPadH, 20);
      expect(UI.cardPadV, 16);
    });

    test('radius getters return scaled values', () {
      UI.markScreenUtilUnready();
      expect(UI.radiusM, 16);
      expect(UI.radiusPill, 999);
    });

    test('icon getters return scaled values', () {
      UI.markScreenUtilUnready();
      expect(UI.iconS, 16);
      expect(UI.iconM, 20);
      expect(UI.iconL, 24);
    });

    test('misc getters return scaled values', () {
      UI.markScreenUtilUnready();
      expect(UI.progressHeight, 6);
      expect(UI.dividerThin, 1);
    });

    test('anim constants are correct', () {
      expect(UI.animFast, const Duration(milliseconds: 180));
      expect(UI.animMedium, const Duration(milliseconds: 220));
    });

    test('_safeScale handles LateInitializationError', () {
      UI.markScreenUtilUnready();
      // This will test the _isLateInitializationError path
      final result = UI.scaleWidth(100);
      expect(result, 100);
    });
  });
}
