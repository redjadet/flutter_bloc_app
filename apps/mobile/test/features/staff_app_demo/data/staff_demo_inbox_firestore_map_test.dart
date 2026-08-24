import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_inbox_firestore_map.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StaffDemoInboxFirestoreMap', () {
    test('recipientFromData maps Timestamp confirmedAt', () {
      final mapped = StaffDemoInboxFirestoreMap.recipientFromData(
        <String, dynamic>{
          'messageId': 'msg-1',
          'confirmedAt': Timestamp.fromMillisecondsSinceEpoch(
            1_700_000_000_000,
          ),
        },
      );
      expect(mapped, isNotNull);
      expect(mapped!.messageId, 'msg-1');
      expect(mapped.confirmedAtMs, 1_700_000_000_000);
    });

    test('recipientFromData skips null or blank messageId', () {
      expect(
        StaffDemoInboxFirestoreMap.recipientFromData(<String, dynamic>{
          'messageId': null,
        }),
        isNull,
      );
      expect(
        StaffDemoInboxFirestoreMap.recipientFromData(<String, dynamic>{
          'messageId': '',
        }),
        isNull,
      );
    });

    test('recipientFromData nulls non-Timestamp confirmedAt', () {
      final mapped = StaffDemoInboxFirestoreMap.recipientFromData(
        <String, dynamic>{
          'messageId': 'msg-2',
          'confirmedAt': 'not-a-timestamp',
        },
      );
      expect(mapped!.confirmedAtMs, isNull);
    });

    test('messageFromData returns null for null document', () {
      expect(StaffDemoInboxFirestoreMap.messageFromData(null), isNull);
    });

    test('messageFromData maps valid string fields', () {
      final StaffDemoInboxMessage? mapped =
          StaffDemoInboxFirestoreMap.messageFromData(<String, dynamic>{
            'body': 'hello',
            'type': 'shift_assignment',
            'shiftId': 'shift-1',
          });
      expect(mapped, isNotNull);
      expect(mapped!.body, 'hello');
      expect(mapped.type, 'shift_assignment');
      expect(mapped.shiftId, 'shift-1');
    });

    test('messageFromData nulls missing and wrong-type optional fields', () {
      final StaffDemoInboxMessage? mapped =
          StaffDemoInboxFirestoreMap.messageFromData(<String, dynamic>{
            'body': 42,
            'type': 'ok',
          });
      expect(mapped, isNotNull);
      expect(mapped!.body, isNull);
      expect(mapped.type, 'ok');
      expect(mapped.shiftId, isNull);
    });
  });
}
