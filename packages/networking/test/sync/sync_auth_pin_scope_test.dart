import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

void main() {
  group('SyncAuthPinScope', () {
    test('restores previous pin after nested scopes', () async {
      expect(SyncAuthPinScope.current, isNull);

      await SyncAuthPinScope.runWithPin('user-a', () async {
        expect(SyncAuthPinScope.current, 'user-a');
        await SyncAuthPinScope.runWithPin('user-b', () async {
          expect(SyncAuthPinScope.current, 'user-b');
        });
        expect(SyncAuthPinScope.current, 'user-a');
      });

      expect(SyncAuthPinScope.current, isNull);
    });
  });
}
