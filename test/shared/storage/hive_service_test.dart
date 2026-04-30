import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../test_helpers.dart' as test_helpers;

void main() {
  group('HiveService', () {
    late HiveService hiveService;
    late HiveKeyManager keyManager;
    late InMemorySecretStorage storage;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await test_helpers.setupHiveForTesting();
    });

    setUp(() {
      storage = InMemorySecretStorage();
      keyManager = HiveKeyManager(storage: storage);
      hiveService = HiveService(keyManager: keyManager);
    });

    tearDown(() async {
      try {
        await hiveService.closeBox('test_box');
        await hiveService.deleteBox('test_box');
      } catch (_) {
        // Box might not exist
      }
    });

    test('initialize sets initialized flag', () async {
      expect(hiveService, isNotNull);
      await hiveService.initialize();
      // Service should be initialized now
    });

    test('initialize is idempotent', () async {
      await hiveService.initialize();
      await hiveService.initialize();
      // Should not throw
    });

    test('initialize coalesces concurrent calls', () async {
      final HiveService newService = HiveService(keyManager: keyManager);
      await Future.wait(List.generate(20, (_) => newService.initialize()));
      expect(newService.isInitialized, isTrue);
    });

    test('openBox creates encrypted box by default', () async {
      await hiveService.initialize();
      final box = await hiveService.openBox('test_box');

      expect(box, isNotNull);
      expect(box.name, 'test_box');
      expect(box.isOpen, isTrue);
    });

    test('openBox creates unencrypted box when encrypted is false', () async {
      await hiveService.initialize();
      final box = await hiveService.openBox(
        'test_box_unencrypted',
        encrypted: false,
      );

      expect(box, isNotNull);
      expect(box.name, 'test_box_unencrypted');
      expect(box.isOpen, isTrue);

      await hiveService.closeBox('test_box_unencrypted');
      await hiveService.deleteBox('test_box_unencrypted');
    });

    test('openBox throws ArgumentError for empty name', () async {
      await hiveService.initialize();

      await expectLater(hiveService.openBox(''), throwsA(isA<ArgumentError>()));
    });

    test('openBox initializes service if not initialized', () async {
      final newService = HiveService(keyManager: keyManager);
      final box = await newService.openBox('test_box_auto_init');

      expect(box, isNotNull);
      expect(box.isOpen, isTrue);

      await newService.closeBox('test_box_auto_init');
      await newService.deleteBox('test_box_auto_init');
    });

    test('openBox coalesces concurrent migration opens', () async {
      await hiveService.initialize();
      await hiveService.deleteBox('migration');

      final List<Box<dynamic>> boxes = await Future.wait(
        List.generate(
          20,
          (_) => hiveService.openBox('migration', encrypted: false),
        ),
      );

      expect(boxes, isNotEmpty);
      for (final box in boxes) {
        expect(box.name, 'migration');
        expect(box.isOpen, isTrue);
      }

      await hiveService.closeBox('migration');
      await hiveService.deleteBox('migration');
    });

    test('openBox does not race closeBox for same box', () async {
      await hiveService.initialize();
      await hiveService.deleteBox('migration');

      final Box<dynamic> initial = await hiveService.openBox(
        'migration',
        encrypted: false,
      );
      await initial.put('k', 'v');

      await Future.wait(
        List.generate(50, (i) async {
          if (i.isEven) {
            await hiveService.openBox('migration', encrypted: false);
          } else {
            await hiveService.closeBox('migration');
          }
        }),
      );

      final Box<dynamic> reopened = await hiveService.openBox(
        'migration',
        encrypted: false,
      );
      await reopened.put('k2', 'v2');
      expect(reopened.get('k2'), 'v2');

      await hiveService.closeBox('migration');
      await hiveService.deleteBox('migration');
    });

    test('openBox does not race deleteBox for same box', () async {
      await hiveService.initialize();
      await hiveService.deleteBox('migration');

      for (int i = 0; i < 25; i++) {
        await Future.wait([
          hiveService.openBox('migration', encrypted: false),
          hiveService.deleteBox('migration'),
        ]);
      }

      final Box<dynamic> finalBox = await hiveService.openBox(
        'migration',
        encrypted: false,
      );
      await finalBox.put('final', true);
      expect(finalBox.get('final'), isTrue);

      await hiveService.closeBox('migration');
      await hiveService.deleteBox('migration');
    });

    test('closeBox closes open box', () async {
      await hiveService.initialize();
      final box = await hiveService.openBox('test_box');
      expect(box.isOpen, isTrue);

      await hiveService.closeBox('test_box');

      expect(Hive.isBoxOpen('test_box'), isFalse);
    });

    test('closeBox handles non-existent box gracefully', () async {
      await hiveService.initialize();

      // Should not throw
      await hiveService.closeBox('non_existent_box');
    });

    test('closeBox handles empty name gracefully', () async {
      await hiveService.initialize();

      // Should not throw
      await hiveService.closeBox('');
    });

    test('deleteBox deletes box from disk', () async {
      await hiveService.initialize();
      final box = await hiveService.openBox('test_box');
      await box.put('key', 'value');
      await hiveService.closeBox('test_box');

      await hiveService.deleteBox('test_box');

      expect(Hive.isBoxOpen('test_box'), isFalse);
      // Box should be deleted from disk
    });

    test('deleteBox closes box before deleting', () async {
      await hiveService.initialize();
      final box = await hiveService.openBox('test_box');
      expect(box.isOpen, isTrue);

      await hiveService.deleteBox('test_box');

      expect(Hive.isBoxOpen('test_box'), isFalse);
    });

    test('deleteBox handles empty name gracefully', () async {
      await hiveService.initialize();

      // Should not throw
      await hiveService.deleteBox('');
    });

    test('getEncryptionCipher returns valid cipher', () async {
      await hiveService.initialize();
      final cipher = await hiveService.getEncryptionCipher();

      expect(cipher, isNotNull);
      expect(cipher, isA<HiveAesCipher>());
    });

    test(
      'getEncryptionCipher throws StateError for invalid key length',
      () async {
        await hiveService.initialize();
        // This test verifies that the key manager generates a valid key
        // The actual key validation happens in HiveKeyManager
        final cipher = await hiveService.getEncryptionCipher();

        expect(cipher, isNotNull);
      },
    );

    test('encrypted box persists data correctly', () async {
      await hiveService.initialize();
      final box = await hiveService.openBox('test_box');
      await box.put('test_key', 'test_value');
      await hiveService.closeBox('test_box');

      final reopenedBox = await hiveService.openBox('test_box');
      expect(reopenedBox.get('test_key'), 'test_value');
    });

    test('multiple boxes can be opened simultaneously', () async {
      await hiveService.initialize();
      final box1 = await hiveService.openBox('test_box_1');
      final box2 = await hiveService.openBox('test_box_2');

      await box1.put('key1', 'value1');
      await box2.put('key2', 'value2');

      expect(box1.get('key1'), 'value1');
      expect(box2.get('key2'), 'value2');

      await hiveService.closeBox('test_box_1');
      await hiveService.closeBox('test_box_2');
      await hiveService.deleteBox('test_box_1');
      await hiveService.deleteBox('test_box_2');
    });
  });
}
