# Staff App Demo Walkthrough

This document is the clearest path to prepare, run, and verify the Staff App
Demo end to end at `/staff-app-demo`.

It is written as an operator checklist, not a product brief.

## What This Covers

The Staff App Demo currently includes these user-facing areas:

- Session + profile hydration
- Role-based bottom navigation
- Messaging and shift confirmation
- Timeclock with flags and Sheets export status
- Published content (PDF / video)
- Forms (availability + manager report)
- Proof submission (photos + signature + offline queue)
- Admin review of recent / flagged time entries

## Test Accounts

The seed script creates these Firebase Auth users:

- `staffdemo.employee@example.com`
- `staffdemo.manager@example.com`
- `staffdemo.accountant@example.com`

All use this password:

- `StaffDemo!234`

## Role Matrix

Use this matrix while testing so you know which account should exercise which
 path.

| Role | Expected bottom tabs | Main actions to verify |
| --- | --- | --- |
| Employee | Home, Time, Msgs, Content, Forms, Proof | confirm assignment, clock in/out, submit availability, submit proof |
| Manager | Home, Time, Msgs, Content, Forms, Proof, Admin | send assignment, confirm employee flow still works, review admin page |
| Accountant | Home, Time, Msgs, Content, Forms, Proof, Admin | same access pattern as manager, especially admin visibility |

## Prerequisites

### Firebase project

This repo is already pointed at:

- Firebase project: `flutter-bloc-app-697e8`

The local project alias is already configured in [.firebaserc](/Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app/.firebaserc).

### Required local files

These should already exist locally for the app to boot against Firebase:

- [android/app/google-services.json](/Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app/android/app/google-services.json)
- [ios/Runner/GoogleService-Info.plist](/Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app/ios/Runner/GoogleService-Info.plist)

### Seed + content setup

Run this before testing if the project is not already seeded:

```bash
set -euo pipefail
STAFF_DEMO_PROJECT_ID=flutter-bloc-app-697e8 \
STAFF_DEMO_SERVICE_ACCOUNT_JSON=fastlane/keys/staff-demo-seeder.json \
STAFF_DEMO_STORAGE_BUCKET=flutter-bloc-app-697e8.firebasestorage.app \
npm --prefix functions run seed:staff-demo
```

The seed script is here:

- [functions/tool/seed_staff_demo.js](/Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app/functions/tool/seed_staff_demo.js)

It seeds:

- demo users
- `staffDemoProfiles/*`
- `staffDemoSites/site1`
- `staffDemoShifts/*`
- `staffDemoContent/*`
- sample Storage objects for published content

### Composite indexes

Deploy indexes before testing Firestore-backed demo flows:

```bash
firebase deploy --only firestore:indexes
```

The index config is:

- [firestore.indexes.json](/Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app/firestore.indexes.json)

Staff demo queries that require composite indexes:

- `staffDemoShifts`: `where(userId == ...)` + `where(startAt <= now)` + `orderBy(startAt desc)`
- `staffDemoMessageRecipients`: `where(userId == ...)` + `orderBy(createdAt desc)`
- `staffDemoContent`: `where(isPublished == true)` + `orderBy(title asc)`

There is also a smoke test for these exact queries:

- [integration_test/staff_app_demo_firestore_query_smoke_test.dart](/Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app/integration_test/staff_app_demo_firestore_query_smoke_test.dart)

## Optional External Integrations

These do not block the app demo itself, but they affect specific outcomes.

### Google Sheets export

Time entry export uses Cloud Functions and requires:

- `STAFF_DEMO_SHEETS_SPREADSHEET_ID`
- `STAFF_DEMO_SHEETS_CREDENTIALS_JSON`

If missing, the time entry should not crash or retry forever. Instead it should
end up with:

- `exportStatus = skipped_missing_config`

### Twilio SMS

SMS delivery requires:

- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_FROM_NUMBER`

If missing, message delivery should still complete and mark:

- `smsSkippedNotConfigured = true`

If the recipient profile has no phone number, delivery should mark:

- `smsSkippedMissingPhone = true`

### Weekly reminder push

The scheduled reminder is disabled unless:

- `STAFF_DEMO_REMINDERS_ENABLED=true`

This is not required for the in-app walkthrough.

## One-Command App Runner

If you already have the simulator/device ready, run:

```bash
flutter run -d "iPhone 17e" -t lib/main_dev.dart
```

Then either:

- navigate from **Example Page** -> **Staff App Demo**
- or open `/staff-app-demo`

## Full Test Path

Run the flow in this order. It keeps setup low and gives the cleanest signal.

### 1. Sign in and verify session gating

Sign in as `staffdemo.employee@example.com`.

Verify on Home:

- the page title is `Staff demo`
- the greeting shows `Hello, ...`
- the page does not show:
  - `No staff demo profile found for this user`
  - `This staff demo profile is inactive.`

If you intentionally want to test the failure states:

- remove `staffDemoProfiles/{uid}` and verify `missingProfile`
- set `isActive=false` and verify `inactive`

### 2. Verify role-based navigation

As employee, verify bottom tabs:

- `Home`
- `Time`
- `Msgs`
- `Content`
- `Forms`
- `Proof`

Verify `Admin` is not visible.

Sign out and repeat as:

- `staffdemo.manager@example.com`
- `staffdemo.accountant@example.com`

Verify `Admin` is visible for both manager and accountant.

### 3. Messaging flow

Use manager or accountant for the send path.

Open `Msgs`.

Verify:

- `Send shift assignment` button is visible for manager/accountant
- it is not visible for employee
- pull down to refresh and verify the inbox reloads

Send a shift assignment with:

- recipient `userId`
- `site1`
- any message body

Verify Firestore:

- `staffDemoShifts/{shiftId}` created with:
  - `userId`
  - `siteId`
  - `status = assigned`
  - `assignedBy`
- `staffDemoMessages/{messageId}` created with:
  - `type = shift_assignment`
  - `shiftId`
  - `body`
- `staffDemoMessageRecipients/{messageId}_{userId}` created with:
  - `messageId`
  - `userId`
  - `createdAt`

Now sign in as the employee recipient.

Open `Msgs` and verify:

- the assignment appears
- the `Confirm` button is visible

Tap `Confirm`.

Verify Firestore:

- `staffDemoMessageRecipients/{messageId}_{userId}.confirmedAt` is set
- `staffDemoShifts/{shiftId}.status = confirmed`
- `staffDemoShifts/{shiftId}.confirmationAt` is set

If Twilio is configured, also verify:

- `smsDeliveredAt`

If Twilio is not configured, verify:

- `smsSkippedNotConfigured = true`

### 4. Timeclock flow

Use the employee account.

Open `Time`.

Verify initial UI:

- if there is no open entry, status reads `clocked out`
- `Clock in` is enabled
- `Clock out` is disabled

Tap `Clock in`.

Verify UI:

- status changes to `clocked in (...)`
- `Clock in` becomes disabled
- `Clock out` becomes enabled
- `Last result flags:` appears after a result is available

Verify Firestore:

- `staffDemoTimeEntries/{entryId}` exists
- it includes:
  - `userId`
  - `siteId`
  - `entryState`
  - `clockInAtClientMs`
  - accuracy / distance fields when available
  - `flags.*`

Tap `Clock out`.

Verify Firestore:

- the same entry updates with:
  - `clockOutAtClientMs`
  - closed `entryState`

Verify Cloud Functions side effects:

- `exportStatus` moves toward:
  - `exported`
  - or `failed`
  - or `skipped_missing_config`

If Sheets is not configured, the expected result is:

- `exportStatus = skipped_missing_config`

### 5. Content flow

Open `Content`.

Verify:

- the list is not empty after seed
- at least one published item exists
- pull down to refresh and verify the list reloads

Tap a PDF item.

Verify:

- a viewer page opens
- the PDF renders instead of failing immediately

Tap a video item if one is seeded.

Verify:

- a video page opens
- playback starts when initialization succeeds
- if the file is invalid, the page shows `Could not load this video.` instead
  of hanging forever

### 6. Forms flow

Open `Forms`.

#### Availability

Toggle one or more days in `Weekly availability`, then submit.

Verify UI:

- status banner shows `Submitting...` and then success

Verify Firestore:

- `staffDemoAvailability/{uid}_{weekStartUtcIso}` exists
- it contains:
  - `userId`
  - `weekStartUtc`
  - `availability`
  - `updatedAt`

#### Manager report

Submit a report with:

- `site1`
- any note text

Verify Firestore:

- `staffDemoManagerReports/{autoId}` exists
- it contains:
  - `userId`
  - `siteId`
  - `notes`
  - `createdAt`

### 7. Proof flow

Open `Proof`.

Verify initial state:

- signature label says `Not saved`
- submit requires a signature

Test validation first:

- tap `Submit` without saving a signature
- verify an error banner appears instead of a silent failure

Now complete the happy path:

- take or pick a photo
- save a signature
- submit proof

Verify UI:

- `Signature saved.` snackbar appears
- success banner shows `Submitted proof ...`

Verify local persistence:

- files are created under the app documents area in `staff_demo/proofs/`

Verify Firebase Storage:

- `staff-app-demo/proofs/{uid}/{proofId}/photos/photo_*.jpg`
- `staff-app-demo/proofs/{uid}/{proofId}/signature.png`

Verify Firestore:

- `staffDemoEventProofs/{proofId}` exists
- it contains:
  - `userId`
  - `siteId`
  - optional `shiftId`
  - `photoStoragePaths`
  - `signatureStoragePath`
  - `createdAt`

#### Offline proof test

Optional but recommended:

- disable network
- submit proof

Verify:

- UI shows `Offline: queued for sync when online.`
- a pending sync operation is enqueued
- after network is restored and sync runs, Storage + Firestore records appear

### 8. Admin flow

Use manager or accountant.

Open `Admin`.

Verify:

- recent entries load
- `Flagged (...)` count appears
- flagged entries list shows:
  - `entryId`
  - `userId`
  - `entryState`
  - `flags`
- pull down to refresh and verify the admin list reloads

If you want a deterministic flagged case:

- create a timeclock result with bad geofence / missing shift conditions
- refresh/reopen `Admin`
- confirm the flagged entry appears

## Suggested End-to-End Order

If you only want one efficient pass, do it in this order:

1. Seed Firebase
2. Deploy Firestore indexes
3. Sign in as manager
4. Verify Home + Admin visibility
5. Send a shift assignment to the employee
6. Sign in as employee
7. Confirm the assignment
8. Run Timeclock
9. Open Content
10. Submit Availability
11. Submit Proof
12. Sign back in as manager/accountant
13. Check Admin page

## Validation Commands

Useful commands around this feature:

```bash
flutter analyze
flutter test test/features/staff_app_demo/presentation/pages/staff_app_demo_happy_path_widget_test.dart
flutter test integration_test/staff_app_demo_firestore_query_smoke_test.dart
firebase deploy --only firestore:indexes
```

For a broader sweep:

```bash
./bin/checklist
```
