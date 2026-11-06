import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

class const CarrierInboxItemDto({
  required final String id,
  required final String kind,
  required final String peerLabel,
  required final String preview,
  required final int occurredAtMs,
  required final bool isUnread,
}) {
  new fromDomain(CarrierInboxItem item)
    : this(
        id: item.id,
        kind: item.kind.name,
        peerLabel: item.peerLabel,
        preview: item.preview,
        occurredAtMs: item.occurredAt.millisecondsSinceEpoch,
        isUnread: item.isUnread,
      );

  factory fromMap(Map<dynamic, dynamic> raw) {
    final Map<String, dynamic> normalized = raw.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
    final String? id = stringFromDynamic(normalized['id']);
    final String? kind = stringFromDynamic(normalized['kind']);
    final String? peerLabel = stringFromDynamic(normalized['peerLabel']);
    if (id == null ||
        id.isEmpty ||
        kind == null ||
        kind.isEmpty ||
        peerLabel == null ||
        peerLabel.isEmpty) {
      throw const FormatException('Invalid CarrierInboxItem payload');
    }
    final String preview = stringFromDynamic(normalized['preview']) ?? '';
    final int? occurredAtMs = intFromDynamic(normalized['occurredAtMs']);
    if (occurredAtMs == null) {
      throw const FormatException('Invalid CarrierInboxItem timestamp');
    }
    final bool isUnread = boolFromDynamic(
      normalized['isUnread'],
      fallback: false,
    );
    return CarrierInboxItemDto(
      id: id,
      kind: kind,
      peerLabel: peerLabel,
      preview: preview,
      occurredAtMs: occurredAtMs,
      isUnread: isUnread,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'kind': kind,
    'peerLabel': peerLabel,
    'preview': preview,
    'occurredAtMs': occurredAtMs,
    'isUnread': isUnread,
  };

  CarrierInboxItem toDomain() {
    final CarrierInboxKind parsedKind = CarrierInboxKind.values.firstWhere(
      (CarrierInboxKind value) => value.name == kind,
      orElse: () => CarrierInboxKind.message,
    );
    return CarrierInboxItem(
      id: id,
      kind: parsedKind,
      peerLabel: peerLabel,
      preview: preview,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(occurredAtMs),
      isUnread: isUnread,
    );
  }
}
