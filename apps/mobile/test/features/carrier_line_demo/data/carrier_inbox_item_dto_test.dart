import 'package:flutter_bloc_app/features/carrier_line_demo/data/carrier_inbox_item_dto.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips domain through map', () {
    final CarrierInboxItem item = CarrierInboxItem(
      id: '1',
      kind: CarrierInboxKind.call,
      peerLabel: 'Ops',
      preview: 'Missed',
      occurredAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
      isUnread: true,
    );
    final CarrierInboxItemDto dto = CarrierInboxItemDto.fromDomain(item);
    final CarrierInboxItem restored = CarrierInboxItemDto.fromMap(dto.toMap())
        .toDomain();
    expect(restored.id, item.id);
    expect(restored.kind, CarrierInboxKind.call);
    expect(restored.peerLabel, 'Ops');
    expect(restored.preview, 'Missed');
    expect(restored.isUnread, isTrue);
    expect(
      restored.occurredAt.millisecondsSinceEpoch,
      item.occurredAt.millisecondsSinceEpoch,
    );
  });

  test('rejects incomplete map', () {
    expect(
      () => CarrierInboxItemDto.fromMap(<String, dynamic>{'id': 'x'}),
      throwsFormatException,
    );
  });
}
