# Staff App Demo Walkthrough

Operator checklist for `/staff-app-demo`. Product brief: see case-study /
feature overview docs if needed.

## Accounts

| Email | Password |
| --- | --- |
| `staffdemo.employee@example.com` | `StaffDemo!234` |
| `staffdemo.manager@example.com` | `StaffDemo!234` |
| `staffdemo.accountant@example.com` | `StaffDemo!234` |

| Role | Tabs | Notes |
| --- | --- | --- |
| Employee | Home, Time, Msgs, Content, Forms, Proof | No Admin |
| Manager / Accountant | + Admin | Send assignments; review flagged time |

Firebase project: `flutter-bloc-app-697e8` ([`.firebaserc`](../../.firebaserc)).

## Setup

```bash
STAFF_DEMO_PROJECT_ID=flutter-bloc-app-697e8 \
STAFF_DEMO_SERVICE_ACCOUNT_JSON=fastlane/keys/staff-demo-seeder.json \
STAFF_DEMO_STORAGE_BUCKET=flutter-bloc-app-697e8.firebasestorage.app \
npm --prefix backend/firebase/functions run seed:staff-demo

firebase deploy --only firestore:indexes
```

- Seed script: `backend/firebase/functions/tool/seed_staff_demo.js`
- Contract fixtures:
  `apps/mobile/test/features/staff_app_demo/data/staff_demo_seed_document_fixtures.dart`
- Indexes: `backend/firebase/indexes/firestore.indexes.json`

```bash
cd apps/mobile && flutter test \
  test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart
```

## Optional integrations

| Integration | Env | Missing behavior |
| --- | --- | --- |
| Sheets export | `STAFF_DEMO_SHEETS_*` | `exportStatus = skipped_missing_config` |
| Twilio SMS | `TWILIO_*` | `smsSkippedNotConfigured` / `smsSkippedMissingPhone` |
| Weekly push | `STAFF_DEMO_REMINDERS_ENABLED=true` | Disabled unless set |

## Run

```bash
flutter run -t apps/mobile/lib/main_dev.dart
```

Example → Staff App Demo, or open `/staff-app-demo`.

## Verify (happy path order)

1. Sign in employee → Home greets; no missing/inactive profile errors.
2. Manager/accountant → Admin tab visible; employee → Admin hidden.
3. Manager sends shift assignment → employee confirms → Firestore
   `staffDemoShifts.status = confirmed`.
4. Employee timeclock in/out → `staffDemoTimeEntries` + export status.
5. Content list opens PDF/video viewers.
6. Forms: availability + manager report docs written.
7. Proof: photo + signature → Storage + `staffDemoEventProofs`; offline queues.
8. Admin: recent + flagged entries refresh.

## Validation

```bash
cd apps/mobile && flutter test \
  test/features/staff_app_demo/presentation/pages/staff_app_demo_happy_path_widget_test.dart
cd apps/mobile && flutter test \
  integration_test/staff_app_demo_firestore_query_smoke_test.dart
./bin/router_feature_validate --paths apps/mobile/lib/features/staff_app_demo
```
