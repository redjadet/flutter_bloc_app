import 'package:flutter_bloc_app/features/carrier_line_demo/data/carrier_inbox_item_dto.dart';
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
      final List<CarrierInboxItem> existing = _loadFromBox(box);
      final List<CarrierInboxItem> updated = List<CarrierInboxItem>.from(
        existing,
      );
      final int index = updated.indexWhere((row) => row.id == item.id);
      if (index == -1) {
        updated.add(item);
      } else {
        updated[index] = item;
      }
      await _save(box, updated);
    }),
  );

  @override
  Future<void> markRead(String id) => StorageGuard.run<void>(
    logContext: 'HiveCarrierInboxRepository.markRead',
    action: () => runWithBox((box) async {
      final List<CarrierInboxItem> existing = _loadFromBox(box);
      final List<CarrierInboxItem> updated = existing
          .map((row) => row.id == id ? row.copyWith(isUnread: false) : row)
          .toList(growable: false);
      await _save(box, updated);
    }),
  );

  /// Seeds once. Empty after a prior seed (or parse-skipped rows) does **not**
  /// reseed — avoids destructive wipe/reseed on malformed payloads.
  ///
  /// If items were persisted but the seed marker write was interrupted, keep
  /// those rows and only complete the marker (do not replace with fixtures).
  @override
  Future<void> ensureSeeded() => StorageGuard.run<void>(
    logContext: 'HiveCarrierInboxRepository.ensureSeeded',
    action: () => runWithBox((box) async {
      final bool alreadySeeded = box.get(_keySeeded) == true;
      if (alreadySeeded) {
        return;
      }
      final List<CarrierInboxItem> existing = _loadFromBox(box);
      if (existing.isNotEmpty) {
        await box.put(_keySeeded, true);
        return;
      }
      final DateTime now = DateTime.now().toUtc();
      await _save(box, <CarrierInboxItem>[
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
      ]);
      await box.put(_keySeeded, true);
    }),
  );

  List<CarrierInboxItem> _loadFromBox(Box<dynamic> box) {
    final Object? raw = box.get(_keyItems);
    if (raw is! Iterable) {
      return const <CarrierInboxItem>[];
    }
    final List<CarrierInboxItem> items =
        raw
            .whereType<Map<dynamic, dynamic>>()
            .map((map) {
              try {
                return CarrierInboxItemDto.fromMap(map).toDomain();
              } on Object {
                // Skip corrupt rows (FormatException, ArgumentError from
                // out-of-range timestamps, etc.) without wiping the box.
                return null;
              }
            })
            .whereType<CarrierInboxItem>()
            .toList(growable: true)
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List<CarrierInboxItem>.unmodifiable(items);
  }

  Future<void> _save(Box<dynamic> box, List<CarrierInboxItem> items) async {
    if (items.isEmpty) {
      await safeDeleteKey(box, _keyItems);
      return;
    }
    final List<Map<String, dynamic>> serialized = items
        .map(CarrierInboxItemDto.fromDomain)
        .map((dto) => dto.toMap())
        .toList(growable: false);
    await box.put(_keyItems, serialized);
  }
}
