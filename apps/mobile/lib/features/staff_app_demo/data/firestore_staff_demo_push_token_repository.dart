import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_result.dart';

class FirestoreStaffDemoPushTokenRepository
    implements StaffDemoPushTokenRepository {
  new({required this._firestore, FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  @override
  Future<StaffDemoPushTokenResult> registerTokens({
    required String userId,
  }) async {
    try {
      final NotificationSettings settings = await _messaging
          .requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied ||
          settings.authorizationStatus ==
              AuthorizationStatus.deniedPermanently) {
        return const StaffDemoPushTokenSkipped(
          StaffDemoPushTokenSkipReason.permissionDenied,
        );
      }

      String? token;
      try {
        token = await _messaging.getToken();
      } on Exception catch (error) {
        // On iOS simulators it is common to see:
        // [firebase_messaging/apns-token-not-set]
        // before APNs registration completes. Treat as expected skip.
        if (error.toString().contains(
          '[firebase_messaging/apns-token-not-set]',
        )) {
          AppLogger.info(
            'FirestoreStaffDemoPushTokenRepository.registerTokens APNs token not set yet; skipping token registration',
          );
          return const StaffDemoPushTokenSkipped(
            StaffDemoPushTokenSkipReason.apnsTokenNotSet,
          );
        }
        rethrow;
      }
      if (token == null || token.isEmpty) {
        return const StaffDemoPushTokenSkipped(
          StaffDemoPushTokenSkipReason.emptyFcmToken,
        );
      }

      String? apnsToken;
      try {
        apnsToken = await _messaging.getAPNSToken();
      } on Exception catch (_) {
        // Expected on simulators or before APNs registration completes.
        AppLogger.info(IntegrationLogMessages.staffDemoPushApnsNotAvailable);
      }

      await _firestore.collection('staffDemoProfiles').doc(userId).set(
        <String, dynamic>{
          'fcmToken': token,
          'apnsToken': apnsToken,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return StaffDemoPushTokenRegistered(hasApnsToken: apnsToken != null);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        IntegrationLogMessages.staffDemoPushRegisterFailed,
        error,
        stackTrace,
      );
      return StaffDemoPushTokenFailed(cause: error, stackTrace: stackTrace);
    }
  }
}
