// ignore_for_file: subtype_of_sealed_class

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/fallback_staff_demo_repositories.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

NotificationSettings _settings(AuthorizationStatus status) =>
    NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.enabled,
      authorizationStatus: status,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.disabled,
      sound: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.disabled,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(SetOptions(merge: true));
  });

  group('FirestoreStaffDemoPushTokenRepository.registerTokens', () {
    late _MockFirebaseMessaging messaging;
    late _MockFirebaseFirestore firestore;
    late FirestoreStaffDemoPushTokenRepository repository;

    setUp(() {
      messaging = _MockFirebaseMessaging();
      firestore = _MockFirebaseFirestore();
      repository = FirestoreStaffDemoPushTokenRepository(
        firestore: firestore,
        messaging: messaging,
      );
    });

    Future<StaffDemoPushTokenResult> register() =>
        AppLogger.silenceAsync(() => repository.registerTokens(userId: 'u1'));

    void stubAuthorizedPermission() {
      when(() => messaging.requestPermission())
          .thenAnswer((_) async => _settings(AuthorizationStatus.authorized));
    }

    void stubFirestoreSet({required Future<void> Function() onSet}) {
      final collection = _MockCollectionReference();
      final document = _MockDocumentReference();
      when(() => firestore.collection('staffDemoProfiles'))
          .thenReturn(collection);
      when(() => collection.doc('u1')).thenReturn(document);
      when(() => document.set(any(), any())).thenAnswer((_) => onSet());
    }

    test(
      'returns Skipped(permissionDenied) when authorization is denied',
      () async {
        when(() => messaging.requestPermission())
            .thenAnswer((_) async => _settings(AuthorizationStatus.denied));

        final StaffDemoPushTokenResult result = await register();

        expect(
          result,
          isA<StaffDemoPushTokenSkipped>().having(
            (StaffDemoPushTokenSkipped s) => s.reason,
            'reason',
            StaffDemoPushTokenSkipReason.permissionDenied,
          ),
        );
        verifyNever(() => messaging.getToken());
      },
    );

    test('returns Skipped(permissionDenied) when authorization is deniedPermanently', () async {
      when(() => messaging.requestPermission()).thenAnswer(
        (_) async => _settings(AuthorizationStatus.deniedPermanently),
      );

      final StaffDemoPushTokenResult result = await register();

      expect(
        result,
        isA<StaffDemoPushTokenSkipped>().having(
          (StaffDemoPushTokenSkipped s) => s.reason,
          'reason',
          StaffDemoPushTokenSkipReason.permissionDenied,
        ),
      );
      verifyNever(() => messaging.getToken());
    });

    test(
      'returns Skipped(apnsTokenNotSet) when getToken reports APNs not ready',
      () async {
        stubAuthorizedPermission();
        when(() => messaging.getToken())
            .thenThrow(Exception('[firebase_messaging/apns-token-not-set]'));

        final StaffDemoPushTokenResult result = await register();

        expect(
          result,
          isA<StaffDemoPushTokenSkipped>().having(
            (StaffDemoPushTokenSkipped s) => s.reason,
            'reason',
            StaffDemoPushTokenSkipReason.apnsTokenNotSet,
          ),
        );
      },
    );

    test('returns Skipped(emptyFcmToken) when getToken returns null', () async {
      stubAuthorizedPermission();
      when(() => messaging.getToken()).thenAnswer((_) async => null);

      final StaffDemoPushTokenResult result = await register();

      expect(
        result,
        isA<StaffDemoPushTokenSkipped>().having(
          (StaffDemoPushTokenSkipped s) => s.reason,
          'reason',
          StaffDemoPushTokenSkipReason.emptyFcmToken,
        ),
      );
    });

    test(
      'returns Skipped(emptyFcmToken) when getToken returns empty string',
      () async {
        stubAuthorizedPermission();
        when(() => messaging.getToken()).thenAnswer((_) async => '');

        final StaffDemoPushTokenResult result = await register();

        expect(
          result,
          isA<StaffDemoPushTokenSkipped>().having(
            (StaffDemoPushTokenSkipped s) => s.reason,
            'reason',
            StaffDemoPushTokenSkipReason.emptyFcmToken,
          ),
        );
      },
    );

    test('returns Failed when getToken throws a non-APNs exception', () async {
      stubAuthorizedPermission();
      when(() => messaging.getToken())
          .thenThrow(Exception('messaging unavailable'));

      final StaffDemoPushTokenResult result = await register();

      expect(
        result,
        isA<StaffDemoPushTokenFailed>()
            .having(
              (StaffDemoPushTokenFailed f) => f.cause.toString(),
              'cause',
              contains('messaging unavailable'),
            )
            .having(
              (StaffDemoPushTokenFailed f) => f.stackTrace,
              'stackTrace',
              isNotNull,
            ),
      );
    });

    test('returns Failed when Firestore set throws', () async {
      stubAuthorizedPermission();
      when(() => messaging.getToken()).thenAnswer((_) async => 'fcm-token');
      when(() => messaging.getAPNSToken()).thenAnswer((_) async => 'apns');
      stubFirestoreSet(
        onSet: () async {
          throw Exception('firestore write failed');
        },
      );

      final StaffDemoPushTokenResult result = await register();

      expect(
        result,
        isA<StaffDemoPushTokenFailed>().having(
          (StaffDemoPushTokenFailed f) => f.cause.toString(),
          'cause',
          contains('firestore write failed'),
        ),
      );
    });

    test(
      'returns Registered when token write succeeds (with APNs token)',
      () async {
        stubAuthorizedPermission();
        when(() => messaging.getToken()).thenAnswer((_) async => 'fcm-token');
        when(() => messaging.getAPNSToken()).thenAnswer((_) async => 'apns');
        stubFirestoreSet(onSet: () async {});

        final StaffDemoPushTokenResult result = await register();

        expect(
          result,
          isA<StaffDemoPushTokenRegistered>().having(
            (StaffDemoPushTokenRegistered r) => r.hasApnsToken,
            'hasApnsToken',
            isTrue,
          ),
        );
      },
    );

    test(
      'returns Registered(hasApnsToken: false) when getAPNSToken throws',
      () async {
        stubAuthorizedPermission();
        when(() => messaging.getToken()).thenAnswer((_) async => 'fcm-token');
        when(() => messaging.getAPNSToken())
            .thenThrow(Exception('apns unavailable'));
        stubFirestoreSet(onSet: () async {});

        final StaffDemoPushTokenResult result = await register();

        expect(
          result,
          isA<StaffDemoPushTokenRegistered>().having(
            (StaffDemoPushTokenRegistered r) => r.hasApnsToken,
            'hasApnsToken',
            isFalse,
          ),
        );
      },
    );
  });

  group('NoOpStaffDemoPushTokenRepository', () {
    test('returns Skipped(repositoryUnavailable)', () async {
      final result = await NoOpStaffDemoPushTokenRepository().registerTokens(
        userId: 'u1',
      );
      expect(
        result,
        isA<StaffDemoPushTokenSkipped>().having(
          (StaffDemoPushTokenSkipped s) => s.reason,
          'reason',
          StaffDemoPushTokenSkipReason.repositoryUnavailable,
        ),
      );
    });
  });

  group('StaffDemoPushTokenSkipReason coverage', () {
    test('enum values are all asserted by repository skip paths', () {
      // Guard against adding a new skip reason without a matching test above.
      expect(
        StaffDemoPushTokenSkipReason.values.toSet(),
        <StaffDemoPushTokenSkipReason>{
          StaffDemoPushTokenSkipReason.permissionDenied,
          StaffDemoPushTokenSkipReason.apnsTokenNotSet,
          StaffDemoPushTokenSkipReason.emptyFcmToken,
          StaffDemoPushTokenSkipReason.repositoryUnavailable,
        },
      );
    });
  });
}
