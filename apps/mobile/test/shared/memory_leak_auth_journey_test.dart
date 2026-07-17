import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/memory/leak_safe_test_widgets.dart';

/// Auth sign-in → sign-out via [ValueNotifier] (dispose ends ownership).
///
/// Uses a minimal [Directionality] tree so MaterialApp harness noise does not
/// dominate. [ValueNotifier] is disposed after unmount.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  leakSafeTestWidgets('auth sign-in then sign-out is leak-safe', (final tester) async {
    final ValueNotifier<AuthUser?> authUser = ValueNotifier<AuthUser?>(null);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder<AuthUser?>(
          valueListenable: authUser,
          builder: (final BuildContext context, final AuthUser? user, _) {
            return Text(user == null ? 'signed-out' : 'signed-in');
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.text('signed-out'), findsOneWidget);

    authUser.value = const AuthUser(id: 'user-1', isAnonymous: false);
    await tester.pump();
    expect(find.text('signed-in'), findsOneWidget);

    authUser.value = null;
    await tester.pump();
    expect(find.text('signed-out'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    authUser.dispose();
  });
}
