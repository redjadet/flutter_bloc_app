abstract interface class StaffDemoPushTokenRepository {
  Future<void> registerTokens({required String userId});
}
