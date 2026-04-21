import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/app_theme.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_tile_config.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_tile_details.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  AppLocalizations.delegate,
];

void main() {
  test('Arabic theme uses bundled Cairo font family', () {
    final textTheme = AppTheme.createArabicTextTheme(
      ThemeData.light().textTheme,
    );

    expect(textTheme.bodyMedium?.fontFamily, AppTheme.arabicFontFamily);
    expect(textTheme.displayLarge?.fontFamily, AppTheme.arabicFontFamily);
  });

  testWidgets('Locale(ar) uses RTL directionality', (final tester) async {
    TextDirection? observed;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: _delegates,
        home: Builder(
          builder: (final context) {
            observed = Directionality.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(observed, TextDirection.rtl);
  });

  testWidgets('ChatContactTileDetails uses directional spacing for time', (
    final tester,
  ) async {
    const timeText = '12:34';
    final contact = ChatContact(
      id: '1',
      name: 'مستخدم',
      lastMessage: 'مرحبا https://example.com 123',
      profileImageUrl: 'https://example.com/image.jpg',
      lastMessageTime: DateTime(2024, 1, 1, 12, 0),
      isOnline: true,
      unreadCount: 1,
    );

    final config = ChatContactTileConfig(
      profileImageSize: 48,
      nameFontSize: 14,
      messageFontSize: 13,
      messageLineHeight: 18,
      timeFontSize: 12,
      textColor: Colors.black,
      subtleTextColor: Colors.black54,
      unreadBackgroundColor: Colors.blue,
      unreadTextColor: Colors.white,
      horizontalPadding: 16,
      verticalPadding: 12,
      horizontalGap: 12,
      responsiveGap: 8,
      isTabletOrLarger: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: _delegates,
        home: Scaffold(
          body: ChatContactTileDetails(
            contact: contact,
            config: config,
            timeText: timeText,
          ),
        ),
      ),
    );

    final timePaddingFinder = find.byWidgetPredicate((final widget) {
      if (widget is! Padding) return false;
      final child = widget.child;
      return child is Text && child.data == timeText;
    });
    expect(timePaddingFinder, findsOneWidget);

    final paddingWidget = tester.widget<Padding>(timePaddingFinder);
    expect(paddingWidget.padding, isA<EdgeInsetsDirectional>());

    final directional = paddingWidget.padding as EdgeInsetsDirectional;
    expect(directional.start, config.messageTimeSpacing);
  });
}
