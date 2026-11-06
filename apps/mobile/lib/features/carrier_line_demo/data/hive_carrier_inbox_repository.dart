import 'package:flutter_bloc_app/features/carrier_line_demo/data/carrier_inbox_hive_payload.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_repository.dart';
import 'package:hive/hive.dart';
import 'package:storage/storage.dart';

class HiveCarrierInboxRepository extends HiveRepositoryBase
    implements CarrierInboxRepository {
  new({required super.hiveService});

  static const String _boxName = 'carrier_line_inbox';
  static const String _keyItems = 'items';
  static const String _keySeeded = 'seeded';
  static const String _schemaNamespace = 'carrier_line_demo:inbox';

  @override
  String get boxName => _boxName;

  @override
  HiveBoxSchema get schema => HiveBoxSchema(
    boxName: _boxName,
    namespace: _schemaNamespace,
    fingerprint:
        hiveSchemaFingerprints[_schemaNamespace] ??
        (throw StateError(
          'Missing hive schema fingerprint for $_schemaNamespace. '
          'Run: dart run tool/generate_hive_schema_fingerprints.dart',
        )),
    migrate: (box, {required fromFingerprint}) async {},
  );

  @override
  Future<List<CarrierInboxItem>> fetchAll() =>
      StorageGuard.run<List<CarrierInboxItem>>(
        logContext: 'HiveCarrierInboxRepository.fetchAll',
        action: () => runWithBox((box) async => _loadFromBox(box)),
        fallback: () async =>
            throw StateError('Carrier line inbox storage unavailable'),
      );

  @override
  Stream<List<CarrierInboxItem>> watchAll() async* {
    final Box<dynamic> box = await getBox();
    yield _loadFromBox(box);
    await for (final BoxEvent event in box.watch()) {
      if (event.key == _keyItems) {
        yield _loadFromBox(box);
      }
    }
  }

  @override
  Future<void> save(CarrierInboxItem item) => StorageGuard.run<void>(
    logContext: 'HiveCarrierInboxRepository.save',
    action: () => runWithBox((box) async {
      final CarrierInboxHivePartition partition = _partition(box);
      rejectMalformedCarrierInboxTopLevel(partition);
      final List<CarrierInboxItem> updated = List<CarrierInboxItem>.from(
        partition.readable,
      );
      final int index = updated.indexWhere((row) => row.id == item.id);
      if (index == -1) {
        updated.add(item);
      } else {
        updated[index] = item;
      }
      await writeCarrierInboxPayload(
        box,
        itemsKey: _keyItems,
        readable: updated,
        unreadable: partition.unreadable,
        deleteKey: (key) => safeDeleteKey(box, key),
      );
    }),
  );

  @override
  Future<void> markRead(String id) => StorageGuard.run<void>(
    logContext: 'HiveCarrierInboxRepository.markRead',
    action: () => runWithBox((box) async {
      final CarrierInboxHivePartition partition = _partition(box);
      rejectMalformedCarrierInboxTopLevel(partition);
      final List<CarrierInboxItem> updated = partition.readable
          .map((row) => row.id == id ? row.copyWith(isUnread: false) : row)
          .toList(growable: false);
      await writeCarrierInboxPayload(
        box,
        itemsKey: _keyItems,
        readable: updated,
        unreadable: partition.unreadable,
        deleteKey: (key) => safeDeleteKey(box, key),
      );
    }),
  );

  /// Seeds once. Empty after a prior seed (or parse-skipped rows) does **not**
  /// reseed — avoids destructive wipe/reseed on malformed payloads.
  ///
  /// Raw [_keyItems] presence is checked separately from parsed rows. If the
  /// key exists (valid partial seed, empty list, or all-unreadable rows), keep
  /// the stored payload and never replace it with fixtures. All-unreadable
  /// rows with a missing seed marker surface a [StateError] instead of
  /// silently reseeding.
  @override
  Future<void> ensureSeeded() => StorageGuard.run<void>(
    logContext: 'HiveCarrierInboxRepository.ensureSeeded',
    action: () => runWithBox((box) async {
      final bool alreadySeeded = box.get(_keySeeded) == true;
      if (alreadySeeded) {
        return;
      }
      if (box.containsKey(_keyItems)) {
        final CarrierInboxHivePartition partition = _partition(box);
        rejectMalformedCarrierInboxTopLevel(partition);
        final bool hasUnreadablePayload =
            partition.unreadable.isNotEmpty && partition.readable.isEmpty;
        if (hasUnreadablePayload) {
          throw StateError(
            'Carrier line inbox payload is present but unreadable; '
            'refusing to reseed',
          );
        }
        await box.put(_keySeeded, true);
        return;
      }
      final DateTime now = DateTime.now().toUtc();
      await writeCarrierInboxPayload(
        box,
        itemsKey: _keyItems,
        readable: <CarrierInboxItem>[
          CarrierInboxItem(
            id: 'seed-call-1',
            kind: CarrierInboxKind.call,
            peerLabel: 'Acme Ops Desk',
            preview: 'Missed · synthetic receptionist fixture',
            occurredAt: now.subtract(const Duration(minutes: 12)),
            isUnread: true,
          ),
          CarrierInboxItem(
            id: 'seed-msg-1',
            kind: CarrierInboxKind.message,
            peerLabel: '+1 (415) 555-0142',
            preview: 'Synthetic SMS preview · not delivered',
            occurredAt: now.subtract(const Duration(hours: 2)),
            isUnread: true,
          ),
          CarrierInboxItem(
            id: 'seed-msg-2',
            kind: CarrierInboxKind.message,
            peerLabel: 'Billing bot',
            preview: 'Synthetic invoice notice · demo only',
            occurredAt: now.subtract(const Duration(days: 1)),
          ),
        ],
        unreadable: const <Object>[],
        deleteKey: (key) => safeDeleteKey(box, key),
      );
      await box.put(_keySeeded, true);
    }),
  );

  List<CarrierInboxItem> _loadFromBox(Box<dynamic> box) {
    final CarrierInboxHivePartition partition = _partition(box);
    rejectMalformedCarrierInboxTopLevel(partition);
    final List<CarrierInboxItem> items = List<CarrierInboxItem>.from(
      partition.readable,
    )..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List<CarrierInboxItem>.unmodifiable(items);
  }

  CarrierInboxHivePartition _partition(Box<dynamic> box) =>
      partitionCarrierInboxBox(box, itemsKey: _keyItems);
}
