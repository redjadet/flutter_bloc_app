import 'dart:io';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/data/hive_carrier_inbox_repository.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:storage/storage.dart';

void main() {
  group('HiveCarrierInboxRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late HiveCarrierInboxRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('carrier_line_inbox_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      repository = HiveCarrierInboxRepository(hiveService: hiveService);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('acceptance: first open seeds once; reopen preserves', () async {
      await repository.ensureSeeded();
      final List<CarrierInboxItem> first = await repository.fetchAll();
      expect(first, isNotEmpty);
      final List<String> ids = first.map((e) => e.id).toList(growable: false);

      await repository.ensureSeeded();
      final List<CarrierInboxItem> second = await repository.fetchAll();
      expect(second.map((e) => e.id), ids);
    });

    test('acceptance: seed flag prevents reseed after empty load', () async {
      await repository.ensureSeeded();
      final Box<dynamic> box = await repository.getBox();
      await box.put('items', <Object?>[]);
      await repository.ensureSeeded();
      expect(await repository.fetchAll(), isEmpty);
    });

    test('markRead clears unread flag', () async {
      await repository.ensureSeeded();
      final CarrierInboxItem unread = (await repository.fetchAll()).firstWhere(
        (CarrierInboxItem row) => row.isUnread,
      );
      await repository.markRead(unread.id);
      final CarrierInboxItem updated = (await repository.fetchAll()).firstWhere(
        (CarrierInboxItem row) => row.id == unread.id,
      );
      expect(updated.isUnread, isFalse);
    });

    test(
      'acceptance: malformed payload skips bad rows; no silent reseed wipe',
      () async {
        await repository.ensureSeeded();
        final List<CarrierInboxItem> seeded = await repository.fetchAll();
        expect(seeded, isNotEmpty);

        final Box<dynamic> box = await repository.getBox();
        await box.put('items', <Object?>[
          <String, Object?>{'id': 'ok-only-partial'},
          <String, Object?>{
            'id': 'kept',
            'kind': 'message',
            'peerLabel': 'Keep',
            'preview': 'Valid',
            'occurredAtMs': DateTime.utc(2026, 2, 1).millisecondsSinceEpoch,
            'isUnread': false,
          },
          <String, Object?>{
            'id': 'bad-ts',
            'kind': 'message',
            'peerLabel': 'Boom',
            'preview': 'Out of range',
            // Far beyond DateTime valid range → ArgumentError in toDomain.
            'occurredAtMs': 1 << 62,
            'isUnread': false,
          },
          'not-a-map',
        ]);

        await repository.ensureSeeded();
        final List<CarrierInboxItem> after = await repository.fetchAll();
        expect(after.map((CarrierInboxItem row) => row.id), <String>['kept']);
        expect(box.get('seeded'), isTrue);
      },
    );

    test(
      'acceptance: partial seed (items without marker) preserves rows',
      () async {
        final Box<dynamic> box = await repository.getBox();
        await box.put('items', <Object?>[
          <String, Object?>{
            'id': 'partial-kept',
            'kind': 'call',
            'peerLabel': 'Saved Peer',
            'preview': 'Persisted before marker',
            'occurredAtMs': DateTime.utc(2026, 3, 1).millisecondsSinceEpoch,
            'isUnread': true,
          },
        ]);
        expect(box.get('seeded'), isNull);

        await repository.ensureSeeded();
        final List<CarrierInboxItem> after = await repository.fetchAll();
        expect(after.map((CarrierInboxItem row) => row.id), <String>[
          'partial-kept',
        ]);
        expect(after.single.isUnread, isTrue);
        expect(box.get('seeded'), isTrue);
      },
    );

    test(
      'regression: malformed items without seed marker are not overwritten',
      () async {
        final Box<dynamic> box = await repository.getBox();
        final List<Object?> malformed = <Object?>[
          <String, Object?>{'id': 'broken-only'},
          'not-a-map',
          <String, Object?>{
            'id': 'bad-ts',
            'kind': 'message',
            'peerLabel': 'Boom',
            'preview': 'Out of range',
            'occurredAtMs': 1 << 62,
            'isUnread': false,
          },
        ];
        await box.put('items', malformed);
        expect(box.get('seeded'), isNull);

        await expectLater(repository.ensureSeeded(), throwsStateError);

        expect(box.get('items'), malformed);
        expect(box.get('seeded'), isNull);
        expect(await repository.fetchAll(), isEmpty);
      },
    );

    test('regression: markRead preserves unrelated malformed rows', () async {
      final Box<dynamic> box = await repository.getBox();
      await box.put('items', <Object?>[
        <String, Object?>{
          'id': 'kept-valid',
          'kind': 'message',
          'peerLabel': 'Keep',
          'preview': 'Valid unread',
          'occurredAtMs': DateTime.utc(2026, 4, 1).millisecondsSinceEpoch,
          'isUnread': true,
        },
        <String, Object?>{'id': 'broken-only'},
        'not-a-map',
        <String, Object?>{
          'id': 'bad-ts',
          'kind': 'message',
          'peerLabel': 'Boom',
          'preview': 'Out of range',
          'occurredAtMs': 1 << 62,
          'isUnread': false,
        },
      ]);
      await box.put('seeded', true);

      await repository.markRead('kept-valid');

      final List<CarrierInboxItem> after = await repository.fetchAll();
      expect(after.single.id, 'kept-valid');
      expect(after.single.isUnread, isFalse);

      final Object? raw = box.get('items');
      expect(raw, isA<Iterable>());
      final List<Object?> rows = List<Object?>.from(raw! as Iterable);
      expect(rows, hasLength(4));
      expect(
        rows.whereType<Map>().any(
          (Map<dynamic, dynamic> row) => row['id'] == 'broken-only',
        ),
        isTrue,
      );
      expect(rows.contains('not-a-map'), isTrue);
      expect(
        rows.whereType<Map>().any(
          (Map<dynamic, dynamic> row) => row['id'] == 'bad-ts',
        ),
        isTrue,
      );
    });

    test('regression: save preserves unrelated malformed rows', () async {
      final Box<dynamic> box = await repository.getBox();
      await box.put('items', <Object?>[
        <String, Object?>{
          'id': 'existing',
          'kind': 'call',
          'peerLabel': 'Peer',
          'preview': 'Existing',
          'occurredAtMs': DateTime.utc(2026, 4, 2).millisecondsSinceEpoch,
          'isUnread': false,
        },
        'not-a-map',
        <String, Object?>{'id': 'broken-only'},
      ]);
      await box.put('seeded', true);

      await repository.save(
        CarrierInboxItem(
          id: 'existing',
          kind: CarrierInboxKind.call,
          peerLabel: 'Peer',
          preview: 'Updated preview',
          occurredAt: DateTime.utc(2026, 4, 2),
        ),
      );

      final CarrierInboxItem updated = (await repository.fetchAll()).single;
      expect(updated.preview, 'Updated preview');

      final List<Object?> rows = List<Object?>.from(
        box.get('items')! as Iterable,
      );
      expect(rows, hasLength(3));
      expect(rows.contains('not-a-map'), isTrue);
      expect(
        rows.whereType<Map>().any(
          (Map<dynamic, dynamic> row) => row['id'] == 'broken-only',
        ),
        isTrue,
      );
    });

    test(
      'regression: seeded malformed top-level fails fetch and watch',
      () async {
        final Box<dynamic> box = await repository.getBox();
        const String stringPayload = 'not-a-list';
        await box.put('items', stringPayload);
        await box.put('seeded', true);

        await expectLater(repository.fetchAll(), throwsStateError);
        expect(box.get('items'), stringPayload);

        await expectLater(repository.watchAll().first, throwsStateError);
        expect(box.get('items'), stringPayload);
      },
    );

    test(
      'regression: malformed top-level map/string payloads are preserved',
      () async {
        final Box<dynamic> box = await repository.getBox();
        const String stringPayload = 'not-a-list';
        await box.put('items', stringPayload);
        expect(box.get('seeded'), isNull);

        await expectLater(repository.ensureSeeded(), throwsStateError);
        expect(box.get('items'), stringPayload);
        expect(box.get('seeded'), isNull);

        await expectLater(repository.markRead('any'), throwsStateError);
        expect(box.get('items'), stringPayload);

        await expectLater(
          repository.save(
            CarrierInboxItem(
              id: 'new',
              kind: CarrierInboxKind.message,
              peerLabel: 'X',
              preview: 'Y',
              occurredAt: DateTime.utc(2026, 5, 1),
            ),
          ),
          throwsStateError,
        );
        expect(box.get('items'), stringPayload);

        final Map<String, Object?> mapPayload = <String, Object?>{
          'id': 'not-a-list',
        };
        await box.put('items', mapPayload);
        await expectLater(repository.ensureSeeded(), throwsStateError);
        expect(box.get('items'), mapPayload);
        await expectLater(repository.markRead('any'), throwsStateError);
        expect(box.get('items'), mapPayload);
        await expectLater(
          repository.save(
            CarrierInboxItem(
              id: 'new',
              kind: CarrierInboxKind.message,
              peerLabel: 'X',
              preview: 'Y',
              occurredAt: DateTime.utc(2026, 5, 1),
            ),
          ),
          throwsStateError,
        );
        expect(box.get('items'), mapPayload);
      },
    );
  });
}
