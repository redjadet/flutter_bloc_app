import 'package:flutter_bloc_app/features/carrier_line_demo/data/carrier_inbox_item_dto.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:hive/hive.dart';
import 'package:storage/storage.dart';

/// Sentinel when the items key exists but the stored value is null.
const Object carrierInboxMissingTopLevelSentinel = Object();

/// Readable domain rows plus quarantined raw entries from a Hive inbox box.
class CarrierInboxHivePartition {
  const CarrierInboxHivePartition({
    required this.readable,
    required this.unreadable,
    this.malformedTopLevel,
  });

  final List<CarrierInboxItem> readable;
  final List<Object> unreadable;

  /// Non-null when the items key exists but is not an [Iterable].
  final Object? malformedTopLevel;
}

CarrierInboxHivePartition partitionCarrierInboxBox(
  Box<dynamic> box, {
  required String itemsKey,
}) {
  if (!box.containsKey(itemsKey)) {
    return const CarrierInboxHivePartition(
      readable: <CarrierInboxItem>[],
      unreadable: <Object>[],
    );
  }
  final Object? raw = box.get(itemsKey);
  if (raw is! Iterable) {
    return CarrierInboxHivePartition(
      readable: const <CarrierInboxItem>[],
      unreadable: const <Object>[],
      malformedTopLevel: raw ?? carrierInboxMissingTopLevelSentinel,
    );
  }
  final List<CarrierInboxItem> readable = <CarrierInboxItem>[];
  final List<Object> unreadable = <Object>[];
  for (final Object? entry in raw) {
    if (entry is! Map) {
      if (entry != null) {
        unreadable.add(entry);
      }
      continue;
    }
    try {
      readable.add(
        CarrierInboxItemDto.fromMap(Map<dynamic, dynamic>.from(entry))
            .toDomain(),
      );
    } on Object {
      unreadable.add(Map<dynamic, dynamic>.from(entry));
    }
  }
  return CarrierInboxHivePartition(readable: readable, unreadable: unreadable);
}

void rejectMalformedCarrierInboxTopLevel(CarrierInboxHivePartition partition) {
  if (partition.malformedTopLevel == null) {
    return;
  }
  throw StateError(
    'Carrier line inbox top-level payload is malformed; '
    'refusing to mutate or reseed',
  );
}

Future<void> writeCarrierInboxPayload(
  Box<dynamic> box, {
  required String itemsKey,
  required List<CarrierInboxItem> readable,
  required List<Object> unreadable,
}) async {
  if (readable.isEmpty && unreadable.isEmpty) {
    await safeDeleteKey(box, itemsKey);
    return;
  }
  final List<Object> serialized = <Object>[
    ...readable
        .map(CarrierInboxItemDto.fromDomain)
        .map((CarrierInboxItemDto dto) => dto.toMap()),
    ...unreadable,
  ];
  await box.put(itemsKey, serialized);
}
