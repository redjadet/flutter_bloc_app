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
      final token = await _messaging.getToken();
      final apnsToken = await _messaging.getAPNSToken();
      if (token == null || token.isEmpty) return;

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
