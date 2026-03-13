import 'package:flutter_bloc_app/shared/sync/fcm_sync_trigger_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FcmSyncTriggerPayload', () {
    test('fromData trims and nulls empty values', () {
      final payload = FcmSyncTriggerPayload.fromData(<String, String>{
        kFcmSyncFeatureKey: '  iot_demo ',
        kFcmSyncResourceTypeKey: ' ',
        kFcmSyncResourceIdKey: '',
      });

      expect(payload.feature, 'iot_demo');
      expect(payload.resourceType, isNull);
      expect(payload.resourceId, isNull);
      expect(payload.isEmpty, isFalse);
    });

    test('toHintString encodes only present keys', () {
      final payload = FcmSyncTriggerPayload(
        feature: 'chat',
        resourceType: 'conversation',
        resourceId: 'conv-1',
      );

      final hint = payload.toHintString();
      expect(hint, contains('"$kFcmSyncFeatureKey":"chat"'));
      expect(hint, contains('"$kFcmSyncResourceTypeKey":"conversation"'));
      expect(hint, contains('"$kFcmSyncResourceIdKey":"conv-1"'));
    });
  });
}
