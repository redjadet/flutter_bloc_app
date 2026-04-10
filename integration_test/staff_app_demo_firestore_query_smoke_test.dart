import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_shift_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Smoke test that executes the Staff Demo Firestore queries that require
/// composite indexes.
///
/// Purpose: fail fast in CI / on-device runs when a new query is added without
/// updating `firestore.indexes.json` + deploying `firestore:indexes`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Staff demo Firestore query preflight (composite indexes)', (
    tester,
  ) async {
    final bool firebaseReady =
        await FirebaseBootstrapService.initializeFirebase();
    expect(
      firebaseReady,
      isTrue,
      reason: 'Firebase must be configured for this smoke test.',
    );

    // Seeded demo credentials (created by `npm --prefix functions run seed:staff-demo`).
    const email = 'staffdemo.manager@example.com';
    const password = 'StaffDemo!234';

    final auth = FirebaseAuth.instance;
    final UserCredential creds = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    addTearDown(() async {
      await auth.signOut();
    });

    final String userId = creds.user?.uid ?? '';
    expect(
      userId,
      isNotEmpty,
      reason: 'Expected a Firebase user uid after sign-in.',
    );

    final firestore = FirebaseFirestore.instance;

    // 1) staffDemoShifts: where(userId) + where(startAt <= now) + orderBy(startAt desc)
    final shiftsRepo = FirestoreStaffDemoShiftRepository(firestore: firestore);
    await shiftsRepo
        .findActiveShift(userId: userId, nowUtc: DateTime.now().toUtc())
        .timeout(const Duration(seconds: 15));

    // 2) staffDemoMessageRecipients: where(userId) + orderBy(createdAt desc)
    final inboxRepo = FirestoreStaffDemoInboxRepository(firestore: firestore);
    await inboxRepo
        .watchRecipients(userId: userId)
        .first
        .timeout(const Duration(seconds: 15));

    // 3) staffDemoContent: where(isPublished == true) + orderBy(title)
    final contentRepo = FirestoreStaffDemoContentRepository(
      firestore: firestore,
      storage: FirebaseStorage.instance,
    );
    await contentRepo.listPublished().timeout(const Duration(seconds: 15));
  });
}
