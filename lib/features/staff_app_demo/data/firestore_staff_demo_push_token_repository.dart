import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class FirestoreStaffDemoPushTokenRepository
    implements StaffDemoPushTokenRepository {
  FirestoreStaffDemoPushTokenRepository({
    required final FirebaseFirestore firestore,
    final FirebaseMessaging? messaging,
  }) : _firestore = firestore,
       _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  @override
  Future<void> registerTokens({required final String userId}) async {
    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }
      String? token;
      try {
        token = await _messaging.getToken();
      } on Exception catch (error) {
        // On iOS simulators it is common to see:
        // [firebase_messaging/apns-token-not-set]
        // before APNs registration completes. Treat as expected noise.
        if (error.toString().contains(
          '[firebase_messaging/apns-token-not-set]',
        )) {
          AppLogger.info(
            'FirestoreStaffDemoPushTokenRepository.registerTokens APNs token not set yet; skipping token registration',
          );
          return;
        }
        rethrow;
      }
      if (token == null || token.isEmpty) return;

      String? apnsToken;
      try {
        apnsToken = await _messaging.getAPNSToken();
      } on Exception catch (_) {
        // Expected on simulators or before APNs registration completes.
        AppLogger.info(
          'FirestoreStaffDemoPushTokenRepository.registerTokens APNs token not available yet',
        );
      }

      await _firestore.collection('staffDemoProfiles').doc(userId).set(
        <String, dynamic>{
          'fcmToken': token,
          'apnsToken': apnsToken,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'FirestoreStaffDemoPushTokenRepository.registerTokens failed',
        error,
        stackTrace,
      );
    }
  }
}
