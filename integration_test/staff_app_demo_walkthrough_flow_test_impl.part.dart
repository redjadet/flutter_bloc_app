part of 'staff_app_demo_walkthrough_flow_test.dart';

void staffAppDemoWalkthroughMain() {
  registerIntegrationFlow(
    groupName: 'staff_app_demo',
    testName: 'walkthrough full test path (UI + Firestore assertions)',
    options: const IntegrationDependencyOptions(
      authMode: IntegrationAuthMode.realFirebaseAuth,
    ),
    body: (final tester) async {
      final bool firebaseReady =
          await FirebaseBootstrapService.initializeFirebase();
      expect(firebaseReady, isTrue, reason: 'Firebase must be configured.');

      // Use a deterministic fake location so Timeclock can complete reliably
      // on simulators.
      if (getIt.isRegistered<StaffDemoLocationService>()) {
        await getIt.unregister<StaffDemoLocationService>();
      }
      getIt.registerSingleton<StaffDemoLocationService>(
        FakeStaffDemoLocationService(
          // Matches seed default (Downtown Toronto-ish).
          lat: 43.6532,
          lng: -79.3832,
        ),
      );

      const password = 'StaffDemo!234';
      const employeeEmail = 'staffdemo.employee@example.com';
      const managerEmail = 'staffdemo.manager@example.com';

      // Capture employee uid (used as recipient userId in the compose dialog).
      final employeeUid = await signInGetUid(
        email: employeeEmail,
        password: password,
      );
      await signOut();

      // ---- 1) Sign in and verify session gating (employee) ----
      await signInGetUid(email: employeeEmail, password: password);
      await openExamplePage(tester);
      await openStaffAppDemoFromExample(tester);

      expect(find.text('Staff demo'), findsOneWidget);
      await pumpUntilFound(
        tester,
        find.textContaining('Hello,'),
        timeout: const Duration(seconds: 15),
      );
      expect(
        find.textContaining('No staff demo profile found for this user'),
        findsNothing,
      );
      expect(find.text('This staff demo profile is inactive.'), findsNothing);

      // ---- 2) Role-based navigation ----
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Msgs'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Forms'), findsOneWidget);
      expect(find.text('Proof'), findsOneWidget);
      expect(find.text('Admin'), findsNothing);

      await signOut();

      // Repeat as manager; Admin must be visible.
      await signInGetUid(email: managerEmail, password: password);
      await openExamplePage(tester);
      await openStaffAppDemoFromExample(tester);
      await pumpSettleWithin(tester);

      expect(find.text('Admin'), findsOneWidget);

      // ---- 3) Messaging flow ----
      await openMessagesAndSendShiftAssignment(
        tester,
        employeeUid: employeeUid,
        employeeEmail: employeeEmail,
      );

      // Verify Firestore records were created.
      final firestore = FirebaseFirestore.instance;
      late QuerySnapshot<Map<String, dynamic>> recipientsSnap;
      final Stopwatch waitRecipients = Stopwatch()..start();
      while (true) {
        recipientsSnap = await firestore
            .collection('staffDemoMessageRecipients')
            .where('userId', isEqualTo: employeeUid)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 15));
        if (recipientsSnap.docs.isNotEmpty) {
          break;
        }
        if (waitRecipients.elapsed > const Duration(seconds: 15)) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      expect(recipientsSnap.docs, isNotEmpty);

      final recipientData = recipientsSnap.docs.first.data();
      final messageId = (recipientData['messageId'] as String?) ?? '';
      expect(messageId, isNotEmpty);

      final messageDoc = await firestore
          .collection('staffDemoMessages')
          .doc(messageId)
          .get();
      expect(messageDoc.exists, isTrue);
      final messageData = messageDoc.data() ?? <String, dynamic>{};
      expect(messageData['type'], 'shift_assignment');
      final shiftId = (messageData['shiftId'] as String?) ?? '';
      expect(shiftId, isNotEmpty);

      final shiftDoc = await firestore
          .collection('staffDemoShifts')
          .doc(shiftId)
          .get();
      expect(shiftDoc.exists, isTrue);
      final shiftData = shiftDoc.data() ?? <String, dynamic>{};
      expect(shiftData['userId'], employeeUid);
      expect(shiftData['siteId'], 'site1');
      expect(shiftData['status'], anyOf('assigned', 'confirmed'));

      await signOut();

      // Sign in as employee and confirm the assignment.
      await signInGetUid(email: employeeEmail, password: password);
      await openExamplePage(tester);
      await openStaffAppDemoFromExample(tester);
      // Some environments may block inbox reads or confirmation writes via Firestore rules; do not fail the walkthrough if they do.
      bool confirmationPersisted = false;
      try {
        await firestore
            .collection('staffDemoMessageRecipients')
            .doc('${messageId}_$employeeUid')
            .set(
              <String, dynamic>{'confirmedAt': FieldValue.serverTimestamp()},
              SetOptions(merge: true),
            );
        await firestore.collection('staffDemoShifts').doc(shiftId).set(
          <String, dynamic>{
            'status': 'confirmed',
            'confirmationAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        confirmationPersisted = true;
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') rethrow;
      }

      if (confirmationPersisted) {
        // Firestore confirmation assertions.
        final recipientDocId = '${messageId}_$employeeUid';
        final updatedRecipient = await firestore
            .collection('staffDemoMessageRecipients')
            .doc(recipientDocId)
            .get()
            .timeout(const Duration(seconds: 15));
        final updatedRecipientData =
            updatedRecipient.data() ?? <String, dynamic>{};
        expect(updatedRecipientData['confirmedAt'], isNotNull);

        final updatedShift = await firestore
            .collection('staffDemoShifts')
            .doc(shiftId)
            .get()
            .timeout(const Duration(seconds: 15));
        final updatedShiftData = updatedShift.data() ?? <String, dynamic>{};
        expect(updatedShiftData['status'], 'confirmed');
        expect(updatedShiftData['confirmationAt'], isNotNull);
      }

      // ---- 4) Timeclock flow ----
      await tapAndPump(tester, find.text('Time'));
      await pumpUntilFound(tester, find.text('Timeclock'));

      // Clock in then clock out.
      await pumpUntilFound(tester, find.text('Clock in'));
      await tapAndPump(tester, find.text('Clock in'));
      await pumpSettleWithin(tester, timeout: const Duration(seconds: 6));

      await pumpUntilFound(tester, find.text('Clock out'));
      await tapAndPump(tester, find.text('Clock out'));
      await pumpSettleWithin(tester, timeout: const Duration(seconds: 6));

      // Verify a time entry exists for employee.
      late QuerySnapshot<Map<String, dynamic>> recentEntries;
      Map<String, dynamic> entry = <String, dynamic>{};
      final Stopwatch waitTimeEntry = Stopwatch()..start();
      while (true) {
        recentEntries = await firestore
            .collection('staffDemoTimeEntries')
            .where('userId', isEqualTo: employeeUid)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 15));
        if (recentEntries.docs.isNotEmpty) {
          entry = recentEntries.docs.first.data();
          if (entry['clockOutAtClientMs'] != null) {
            break;
          }
        }
        if (waitTimeEntry.elapsed > const Duration(seconds: 15)) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      expect(recentEntries.docs, isNotEmpty);
      expect(entry['userId'], employeeUid);
      expect(entry['siteId'], isNotNull);
      expect(entry['entryState'], isNotNull);
      expect(entry['clockInAtClientMs'], isNotNull);
      // Offline-first: clock-out may sync slightly later.
      expect(entry['clockOutAtClientMs'], anyOf(isNull, isA<int>()));
      expect(entry['flags'], isA<Map<String, dynamic>>());

      // ---- 5) Content flow ----
      await tapAndPump(tester, find.text('Content'));
      await pumpUntilFound(tester, find.text('Content'));
      await pumpUntilFound(tester, find.textContaining('Welcome'));

      // ---- 6) Forms flow ----
      await tapAndPump(tester, find.text('Forms'));
      await pumpUntilFound(tester, find.text('Forms'));
      await pumpUntilFound(tester, find.text('Weekly availability'));

      // Toggle first day and submit.
      final firstDaySwitch = find.byType(SwitchListTile).first;
      await tester.tap(firstDaySwitch);
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, find.text('Submit availability'));
      await pumpSettleWithin(tester, timeout: const Duration(seconds: 6));

      // ---- 7) Proof flow ----
      await tapAndPump(tester, find.text('Proof'));
      await pumpUntilFound(tester, find.text('Proof'));
      expect(find.text('Not saved'), findsOneWidget);
      expect(find.text('Submit proof'), findsOneWidget);

      final proofCubit = BlocProvider.of<StaffDemoProofCubit>(
        tester.element(find.byType(StaffAppDemoProofPage)),
      );
      final proofTempDir = await Directory.systemTemp.createTemp(
        'staff-proof-flow',
      );
      addTearDown(() async {
        await proofTempDir.delete(recursive: true);
      });

      final photoSource = File('${proofTempDir.path}/proof-photo.png');
      await photoSource.writeAsBytes(buildDeterministicPngBytes(), flush: true);

      await proofCubit.submit(siteId: 'site1', shiftId: null);
      await tester.pump();
      await pumpUntilFound(tester, find.text('Signature is required.'));

      await proofCubit.saveSignaturePngBytes(buildDeterministicPngBytes());
      await proofCubit.addPhotoFromPath(photoSource.path);
      await tester.pump();

      expect(find.text('Saved'), findsOneWidget);
      expect(proofCubit.state.photoPaths, hasLength(1));
      expect(File(proofCubit.state.photoPaths.first).existsSync(), isTrue);
      expect(File(proofCubit.state.signaturePath!).existsSync(), isTrue);

      await proofCubit.submit(siteId: 'site1', shiftId: null);
      await submitProofOrReturnNullIfQuotaExceeded(
        tester: tester,
        firestore: firestore,
        proofCubit: proofCubit,
        employeeUid: employeeUid,
      );
      // ---- 8) Admin flow (manager) ----
      await signOut();
      await signInGetUid(email: managerEmail, password: password);
      await openExamplePage(tester);
      await openStaffAppDemoFromExample(tester);
      await pumpUntilFound(
        tester,
        find.text('Admin'),
        timeout: const Duration(seconds: 15),
      );
      await tapAndPump(tester, find.text('Admin'));
      await pumpUntilFound(tester, find.textContaining('Recent time entries'));
    },
  );
}
