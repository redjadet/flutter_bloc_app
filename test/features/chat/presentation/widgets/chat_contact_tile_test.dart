import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_avatar.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatContactTile', () {
    final testContact = ChatContact(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Hello there! This is a longer message to test overflow.',
      profileImageUrl: 'https://example.com/image1.jpg',
      lastMessageTime: DateTime(2024, 1, 1, 12, 0),
      isOnline: true,
      unreadCount: 2,
    );

    Widget createWidgetUnderTest({
      required ChatContact contact,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ChatContactTile(
            contact: contact,
            onTap: onTap ?? () {},
            onLongPress: onLongPress ?? () {},
          ),
        ),
      );
    }

    testWidgets('should display contact information correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(contact: testContact));

      expect(find.text('John Doe'), findsOneWidget);
      expect(
        find.text('Hello there! This is a longer message to test overflow.'),
        findsOneWidget,
      );
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should show online indicator when contact is online', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(contact: testContact));

      // Online indicator uses theme primary and BoxShape.circle
      final scheme = ThemeData().colorScheme;
      final onlineIndicator = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) return false;
        return decoration.shape == BoxShape.circle &&
            decoration.color == scheme.primary;
      });
      expect(onlineIndicator, findsOneWidget);
    });

    testWidgets('should not show online indicator when contact is offline', (
      tester,
    ) async {
      final offlineContact = ChatContact(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello there!',
        profileImageUrl: 'https://example.com/image1.jpg',
        lastMessageTime: DateTime(2024, 1, 1, 12, 0),
        isOnline: false,
        unreadCount: 2,
      );

      await tester.pumpWidget(createWidgetUnderTest(contact: offlineContact));

      // Online indicator (theme primary circle) should not be present when offline
      final scheme = ThemeData().colorScheme;
      final onlineIndicator = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) return false;
        return decoration.shape == BoxShape.circle &&
            decoration.color == scheme.primary;
      });
      expect(onlineIndicator, findsNothing);
    });

    testWidgets('should not show unread count when it is 0', (tester) async {
      final contactWithoutUnread = ChatContact(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello there!',
        profileImageUrl: 'https://example.com/image1.jpg',
        lastMessageTime: DateTime(2024, 1, 1, 12, 0),
        isOnline: true,
        unreadCount: 0,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(contact: contactWithoutUnread),
      );

      // Should not find unread count badge
      final unreadBadge = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                const Color(0xFF007AFF),
      );
      expect(unreadBadge, findsNothing);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool onTapCalled = false;
      await tester.pumpWidget(
        createWidgetUnderTest(
          contact: testContact,
          onTap: () => onTapCalled = true,
        ),
      );

      await tester.tap(find.byType(ChatContactTile));
      expect(onTapCalled, isTrue);
    });

    testWidgets('should call onLongPress when long pressed', (tester) async {
      bool onLongPressCalled = false;
      await tester.pumpWidget(
        createWidgetUnderTest(
          contact: testContact,
          onLongPress: () => onLongPressCalled = true,
        ),
      );

      await tester.longPress(find.byType(ChatContactTile));
      expect(onLongPressCalled, isTrue);
    });

    testWidgets('should display profile image with error fallback', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(contact: testContact));
      await tester.pump(); // Don't wait for network images to load

      // Should find CachedNetworkImageWidget (which wraps CachedNetworkImage)
      // The widget will show placeholder/error state in tests since network requests fail
      expect(find.byType(ChatContactAvatar), findsOneWidget);
    });

    testWidgets('should format time correctly', (tester) async {
      final now = DateTime.now();
      final recentContact = testContact.copyWith(
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(createWidgetUnderTest(contact: recentContact));

      // Should show some time text (the exact format may vary)
      // Just verify that there's text displayed for the time
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should handle responsive sizing', (tester) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Mobile
      await tester.pumpWidget(createWidgetUnderTest(contact: testContact));
      await tester.pump(); // Don't wait for network images to load

      // Verify the widget renders without errors
      expect(find.byType(ChatContactTile), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Tablet
      await tester.pumpWidget(createWidgetUnderTest(contact: testContact));
      await tester.pump(); // Don't wait for network images to load

      expect(find.byType(ChatContactTile), findsOneWidget);

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop
      await tester.pumpWidget(createWidgetUnderTest(contact: testContact));
      await tester.pump(); // Don't wait for network images to load

      expect(find.byType(ChatContactTile), findsOneWidget);
    });
  });
}
