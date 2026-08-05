import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_inbox_firestore_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StaffDemoInboxFirestoreMap', () {
    test('recipientFromData maps Timestamp confirmedAt', () {
      final mapped =
          StaffDemoInboxFirestoreMap.recipientFromData(<String, dynamic>{
            'messageId': 'msg-1',
            'confirmedAt': Timestamp.fromMillisecondsSinceEpoch(
              1_700_000_000_000,
            ),
          });
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

    test('messageFromData preserves identity including null', () {
      expect(StaffDemoInboxFirestoreMap.messageFromData(null), isNull);
      final Map<String, dynamic> raw = <String, dynamic>{'body': 'hi'};
      expect(
        identical(StaffDemoInboxFirestoreMap.messageFromData(raw), raw),
        isTrue,
      );
    });
  });
}
