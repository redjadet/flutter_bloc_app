/// Kind of inbox row for the business phone line demo.
enum CarrierInboxKind { call, message }

/// One offline-cached call or message thread preview.
class const CarrierInboxItem({
  required final String id,
  required final CarrierInboxKind kind,
  required final String peerLabel,
  required final String preview,
  required final DateTime occurredAt,
  final bool isUnread = false,
}) {
  CarrierInboxItem copyWith({
    String? peerLabel,
    String? preview,
    DateTime? occurredAt,
    bool? isUnread,
  }) => CarrierInboxItem(
    id: id,
    kind: kind,
    peerLabel: peerLabel ?? this.peerLabel,
    preview: preview ?? this.preview,
    occurredAt: occurredAt ?? this.occurredAt,
    isUnread: isUnread ?? this.isUnread,
  );
}
