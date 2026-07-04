# Firebase Setup (Run the App with Firebase)

The repo includes a **placeholder** `lib/firebase_options.dart` so the project **compiles and runs** even when Firebase is not configured. In that case the app skips Firebase initialization and runs with Firebase-dependent features disabled (no crash, no login required).

**Web builds** additionally use [BackendAvailability](../lib/core/config/backend_availability.dart) “no-backend mode”: Firebase and Supabase are opportunistic when configured, but never required for navigation, guest access, or local demo fallbacks (Chat/IoT). See [changes/2026-06-17_web-no-backend-mode.md](changes/2026-06-17_web-no-backend-mode.md).

To run this app **with** Firebase (Auth, Remote Config, Realtime Database, Crashlytics, etc.), add your own configuration as below.

- **Gitignored (local only):** `firebase.json`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `macos/Runner/GoogleService-Info.plist`, and `.envrc`.
- **Committed template:** [`firebase.json.example`](../firebase.json.example) — copy to `firebase.json` and set your `projectId` / app IDs (or run `flutterfire configure`, which writes `firebase.json` for you).
- **Committed (placeholders only):** `lib/firebase_options.dart` uses `String.fromEnvironment('FIREBASE_*', …)` so real API keys are injected via `--dart-define`, not hardcoded in git.
- **`flutterfire configure`** downloads platform files and *can* overwrite `lib/firebase_options.dart` with hardcoded keys — restore the committed placeholder after configuring (see [step 3b](#3b-after-flutterfire-configure-do-not-commit-generated-dart)) and put values in `.envrc` instead.

Before committing, run `./tool/check_tracked_secret_literals.sh`.

## Fresh checkout and local templates

Fresh checkouts must build and run without local Firebase files. The app uses
the committed `lib/firebase_options.dart` placeholders and skips Firebase
initialization when required `FIREBASE_*` values are missing. Platform build
steps also skip optional Firebase upload/processing when local config is absent
(including Debug/simulator Crashlytics symbol upload via
[`tool/patch_ios_flutterfire_crashlytics_upload.sh`](../tool/patch_ios_flutterfire_crashlytics_upload.sh)).

Use these tracked templates only when you want Firebase-backed features locally:

| Gitignored local file | Tracked template | Fresh-checkout behavior |
| --- | --- | --- |
| `firebase.json` | [`firebase.json.example`](../firebase.json.example) | Optional; Crashlytics symbol upload skips when absent. |
| `android/app/google-services.json` | [`android/app/google-services.json.sample`](../android/app/google-services.json.sample) | Optional; Android skips Google Services / Crashlytics Gradle plugins when absent. |
| `ios/Runner/GoogleService-Info.plist` | [`ios/Runner/GoogleService-Info.plist.sample`](../ios/Runner/GoogleService-Info.plist.sample) | Optional; iOS copies it into `Runner.app` only when present. |
| `macos/Runner/GoogleService-Info.plist` | [`macos/Runner/GoogleService-Info.plist.sample`](../macos/Runner/GoogleService-Info.plist.sample) | Optional; macOS does not require it as a build resource. |
| `.envrc` | [`docs/envrc.example`](envrc.example) | Optional; without it Firebase and remote-secret features stay disabled. |
| `assets/config/secrets.json` | [`assets/config/secrets.sample.json`](../assets/config/secrets.sample.json) | Optional; not bundled by default. |

Do not commit copied local files after replacing placeholders with real project
values. Keep real values in the gitignored paths above.

### Backend assets (Melos workspace)

Firebase backend sources live under `backend/firebase/`:

| Asset | Path |
| --- | --- |
| Cloud Functions | `backend/firebase/functions/` |
| Firestore rules | `backend/firebase/firestore_rules/firestore.rules` |
| Firestore indexes | `backend/firebase/indexes/firestore.indexes.json` |
| Storage rules | `backend/firebase/storage_rules/storage.rules` |

[`firebase.json.example`](../firebase.json.example) points at these paths. After
copying to gitignored `firebase.json`, deploy with `firebase deploy` from the
repo root. Functions tests: `cd backend/firebase/functions && npm ci && npm test`.

---

## Option A: FlutterFire CLI (recommended)

This generates all required files from your Firebase project in one step.

### 1. Install the FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Ensure the global pub cache is on your `PATH` (e.g. `export PATH="$PATH:$HOME/.pub-cache/bin"`).

### 2. Log in to Firebase (if needed)

```bash
firebase login
```

### 3. Configure Firebase for this project

From the **repository root** (example for this repo’s default project):

```bash
flutterfire configure \
  --project=flutter-bloc-app-697e8 \
  --yes \
  --platforms=android,ios,macos \
  --android-package-name=com.ilkersevim.blocflutter \
  --ios-bundle-id=com.example.flutterBlocApp \
  --macos-bundle-id=com.example.flutterBlocApp
```

Omit flags to pick the project and platforms interactively.

This will:

- Create a new Firebase project or let you select an existing one
- Register Android and iOS (and optionally macOS) apps with the correct package name / bundle ID from your Flutter project
- Download platform config files and generate a Dart options file (see step 3b before committing)

| File | Location | In git |
| ------ | ---------- | ------ |
| Android | `android/app/google-services.json` | gitignored |
| iOS | `ios/Runner/GoogleService-Info.plist` | gitignored |
| macOS | `macos/Runner/GoogleService-Info.plist` | gitignored |
| Dart | `lib/firebase_options.dart` | **committed placeholder** — do not commit hardcoded keys from the CLI |

### 3b. After `flutterfire configure` (do not commit generated Dart)

`flutterfire configure` writes **hardcoded** API keys into `lib/firebase_options.dart`. Keep the repo’s committed placeholder instead:

1. Copy `apiKey`, `appId`, `projectId`, and related fields into `.envrc` as `FIREBASE_*` exports (see [`docs/envrc.example`](envrc.example)).
2. Restore the committed placeholder Dart file:

   ```bash
   git checkout HEAD -- lib/firebase_options.dart
   ```

3. Load env and verify key names (not values):

   ```bash
   direnv allow
   ./tool/flutter_dart_defines_from_env.sh | tr ' ' '\n' | sed -n 's/^--dart-define=\([^=]*\)=.*/\1/p' | grep '^FIREBASE_'
   ```

4. Run `./tool/check_tracked_secret_literals.sh` before any commit.

Native builds use the gitignored plist/json files; Dart uses `--dart-define` from `.envrc`.

### 4. Run the app

```bash
bash tool/workspace_pub_get.sh
cd apps/mobile && flutter run -t lib/main_dev.dart
```

---

## Option B: Manual setup (Firebase Console)

If you prefer not to use the CLI:

1. **Create or open a project** at [Firebase Console](https://console.firebase.google.com/).

2. **Add an Android app**
   - Use the **Android package name** from `android/app/build.gradle` (`applicationId`).
   - Download `google-services.json` and place it at **`android/app/google-services.json`**.

3. **Add an iOS app**
   - Use the **bundle identifier** from `ios/Runner/Info.plist` (e.g. `CFBundleIdentifier`).
   - Download `GoogleService-Info.plist` and place it at **`ios/Runner/GoogleService-Info.plist`**.
   - The Xcode project has a conditional build phase that copies this gitignored
     plist into `Runner.app` when present. Do not add the local plist itself to
     source control.

4. **Add a macOS app** (optional, only if you run on macOS desktop)
   - Use the macOS bundle ID from your Xcode project.
   - Download `GoogleService-Info.plist` and place it at **`macos/Runner/GoogleService-Info.plist`**.

5. **Dart options (local injection)**
   - Prefer [Option A](#option-a-flutterfire-cli-recommended) plus [step 3b](#3b-after-flutterfire-configure-do-not-commit-generated-dart): platform files from the CLI, `FIREBASE_*` in `.envrc`, committed `lib/firebase_options.dart` stays a placeholder.
   - Or copy values from platform files into `.envrc` only; do not hardcode API keys into the committed Dart file.

6. **Run the app**

   ```bash
   bash tool/workspace_pub_get.sh
   cd apps/mobile && flutter run -t lib/main_dev.dart
   ```

---

## What works with Firebase

Once config is in place:

- **Firebase Auth** – Email and Google sign-in (Firebase UI)
- **Firebase Remote Config** – Feature flags and remote values
- **Firebase Realtime Database** – Todo list sync and counter sync (see rules below)
- **Firebase Crashlytics** – Crash reporting
- **WalletConnect Auth demo** – Links wallet to Firebase Auth and stores profile in Firestore
- **FCM** – Push notifications (FCM demo feature)
- **Charts (Firebase fallback)** – When Supabase is not usable but Firebase Auth is signed in, charts fetch via a callable Cloud Function with Firestore fallback (see below).

---

## Before debugging Firebase features locally

1. Decide whether this debug session needs Firebase. Non-Firebase screens should
   run with placeholders; Firebase init skips safely when required values are
   missing.
2. If Firebase is needed, populate `.envrc` with `FIREBASE_*` values from your
   local Firebase project and run `direnv allow`.
3. Verify the wrapper sees the keys without printing values:
   `./tool/flutter_dart_defines_from_env.sh | tr ' ' '\n' | sed -n 's/^--dart-define=\([^=]*\)=.*/\1/p'`.
4. Confirm platform files are present only in gitignored paths when native
   build tooling needs them: `android/app/google-services.json`,
   `ios/Runner/GoogleService-Info.plist`, and
   `macos/Runner/GoogleService-Info.plist`.
5. Run `./tool/check_tracked_secret_literals.sh` before committing any Firebase
   config change.
6. If iOS/macOS native config changed, run `flutter clean`, `flutter pub get`,
   and `cd ios && pod install && cd ..` before debug.
7. Start with `cd apps/mobile && flutter run -t lib/main_dev.dart`, or root
   `flutter run -t lib/main_dev.dart` when the direnv wrapper is active. If
   Firebase still does not initialize, read the log line listing missing field
   names and add only those `FIREBASE_*` values to `.envrc`.

---

## Firebase workflow preflight (project mismatch guard)

Firebase deploy and distribution scripts in this repo run a preflight check:

- Expected Firebase project ID for this checkout comes from `.firebaserc` (`projects.default`).
- The preflight compares that against your active Firebase CLI project (`firebase use --json`).
- For App Distribution uploads, [`tool/upload_ios_to_firebase_app_distribution.sh`](../tool/upload_ios_to_firebase_app_distribution.sh) calls [`tool/firebase_preflight.sh`](../tool/firebase_preflight.sh) with `--app-id` so the iOS **App ID** prefix matches the expected project number (see [Firebase App Distribution](firebase_app_distribution.md#ios-upload-script)).

You can run the same check manually:

```bash
./tool/firebase_preflight.sh --require-cli --app-id "1:473097776453:ios:6962f6ddc4d7ea12bd222c"
```

If it fails, run:

```bash
firebase login
firebase use flutter-bloc-app-697e8
```

## Secret scanning alerts

Review open alerts at [GitHub secret scanning](https://github.com/redjadet/flutter_bloc_app/security/secret-scanning) for this repo.

If GitHub secret scanning flags a Firebase/Google API key:

1. **Rotate or restrict** the key in [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials (and Firebase Console if needed). Treat `publicly_leaked: true` alerts as compromised even after removal from `main`.
2. **Current tree:** replace any tracked literals with placeholders (`YOUR_*_API_KEY`, `your-project-id`, `1:000000000000:*:placeholder`). Keep real keys only in gitignored paths (`.envrc`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `macos/Runner/GoogleService-Info.plist`).
3. Run `./tool/check_tracked_secret_literals.sh` before pushing.
4. **Resolve** the GitHub alert (`revoked` after rotation, or `false_positive` only for third-party example keys that are not yours).
5. **Git history:** removing secrets from `main` does not erase old commits. To scrub all refs locally (requires a coordinated force-push):

   ```bash
   # Requires git-filter-repo (e.g. brew install git-filter-repo)
   git filter-repo --replace-text tool/firebase_secret_history_replacements.txt --force
   git remote add origin git@github.com:redjadet/flutter_bloc_app.git   # filter-repo removes origin
   git push --force --all origin
   git push --force --tags origin
   ```

   All collaborators must **re-clone** or hard-reset to the new history. Forks and cached clones may retain old SHAs until garbage-collected.

If one or more required `FIREBASE_*` values are missing from local direnv, the
app skips Firebase initialization and logs the missing field names only. Firebase
UI/Auth setup becomes a no-op in that state so local development can still use
non-Firebase features.

---

## Cloud Functions (TypeScript) – Charts fallback

This repo includes Firebase Cloud Functions under `functions/` (TypeScript, Node 22).

### Callable used by the chart demo

- **Function:** `syncChartTrending` (callable), region `us-central1`
- **Auth:** required (call rejects when unauthenticated)
- **Firestore doc:** `chart_trending/bitcoin_7d`
- **Freshness gate:** returns Firestore points when `updatedAt` is newer than ~15 minutes; otherwise fetches CoinGecko and refreshes Firestore.

### Gen2 (Node 22) IAM note (important)

For Gen2 callable functions, Cloud Functions runs on Cloud Run. The callable client can fail with a misleading `UNAUTHENTICATED` when the underlying service is blocked by Cloud Run IAM (401 “not authorized to invoke this service”).

If you see that symptom, allow invocation of the Cloud Run service:

```bash
gcloud run services add-iam-policy-binding synccharttrending \
  --region us-central1 \
  --member="allUsers" \
  --role="roles/run.invoker"
```

Security is still enforced by the callable auth check inside the function (`request.auth` must be present).

---

## Optional: Realtime Database rules (Todo list)

If you use the **Todo list** or **Counter** sync with Realtime Database, deploy rules so the app can read/write. In Firebase Console: **Build → Realtime Database → Rules**.

Full rules and explanation: [Todo List Firebase Realtime Database Security Rules](todo_list_firebase_security_rules.md).

---

## Optional: Auth (Email / Google)

- **Email/Password**: Enable in Firebase Console under **Build → Authentication → Sign-in method**.
- **Google**: Enable the Google provider and, for iOS, add the URL scheme from `GoogleService-Info.plist` into `ios/Runner/Info.plist` (often done automatically when you add the Firebase iOS app).

---

## Troubleshooting

| Issue | What to do |
| ----- | ---------- |
| **Firebase not initializing** | The app skips Firebase init when required `FIREBASE_*` values are missing or still placeholders (e.g. `your-project-id`). Add real values to `.envrc`, run `direnv allow`, and ensure gitignored platform files exist (`flutterfire configure` — then [step 3b](#3b-after-flutterfire-configure-do-not-commit-generated-dart)). |
| **`flutterfire configure` fails** (e.g. "Failed to write Dart configuration file", "UnsupportedError not found in macOS", or **"FormatException: Unexpected character (at character 1)"**) | See [Workaround when FlutterFire CLI fails on macOS](#workaround-when-flutterfire-cli-fails-on-macos) below. The FormatException often means the CLI got non-JSON output from a Firebase command (e.g. login prompt or proxy/network issue). |
| **Missing google-services.json** | Fresh-checkout debug builds should still work. For Firebase-backed Android features, copy `android/app/google-services.json.sample` to `android/app/google-services.json` and replace placeholders, or run `flutterfire configure`. |
| **Missing GoogleService-Info.plist** | Fresh-checkout iOS/macOS builds should still work. For Firebase-backed Apple features, copy the matching `.sample` plist and replace placeholders, or run `flutterfire configure`. On iOS, the project copies `ios/Runner/GoogleService-Info.plist` into `Runner.app` only when that local file exists; if `FirebaseApp.configure()` crashes with “Could not locate configuration file,” confirm the source plist exists and rebuild from Xcode/Flutter so the copy phase runs. **Integration:** `./bin/integration_tests` skips or removes placeholder plists (`YOUR_IOS_API_KEY`) before simulator runs; `AppDelegate` skips native configure when the plist is missing or still a placeholder. |
| **iOS build errors after Firebase changes** | See [Common Troubleshooting](new_developer_guide.md#common-troubleshooting) (“Firebase upgrades break iOS build”) for clean steps (e.g. `flutter clean`, reinstall pods). |
| **Todo list / Counter sync permission denied** | Deploy [Realtime Database rules](todo_list_firebase_security_rules.md) and ensure the user is signed in. |
| **Charts show `UNAUTHENTICATED` but a Firebase user exists** | Check Cloud Run IAM for the Gen2 callable (see “Gen2 (Node 22) IAM note” above). |
| **App Check errors on iOS simulator** | This repo skips App Check activation on iOS simulators in debug (“monitoring-only demo”). In production, use App Attest / DeviceCheck and enforce App Check as needed. |

### Workaround when FlutterFire CLI fails on macOS

If `flutterfire configure` fails with **"Failed to write Dart configuration file"** and **"UnsupportedError not found in macOS"** (a known [FlutterFire CLI issue](https://github.com/invertase/flutterfire_cli/issues)):

1. **Try installing the Ruby `xcodeproj` gem** (required by the CLI on macOS), then re-run:

   ```bash
   gem install xcodeproj
   flutterfire configure
   ```

   If you get permission errors, use `sudo gem install xcodeproj`.

2. **If it still fails**, generate `lib/firebase_options.dart` manually from your existing platform config:
   - Copy `lib/firebase_options.dart.sample` to `lib/firebase_options.dart`.
   - Replace the placeholders with values from your Firebase project: open `android/app/google-services.json` for `project_id`, `project_number`, Android `api_key` and `mobilesdk_app_id`; open `ios/Runner/GoogleService-Info.plist` (or run `plutil -p ios/Runner/GoogleService-Info.plist`) for `API_KEY`, `GOOGLE_APP_ID`, `GCM_SENDER_ID`, `STORAGE_BUCKET`, `BUNDLE_ID`, `CLIENT_ID`. Use the same structure as the sample (android / ios / macos `FirebaseOptions` and `currentPlatform` getter).

---

## Related docs

- [Security & Secrets](security_and_secrets.md) – API keys (Hugging Face, Gemini, Maps) via `SecretConfig`; Firebase platform files are separate and not part of that secrets flow.
- [Deployment](deployment.md) – Store/CI, Fastlane (`release_both_stores.sh`, `fastlane.sh`), and Firebase config file locations.
- [WalletConnect Auth Status](walletconnect_auth_status.md) – Demo Firebase setup for WalletConnect.
- [Developer Guide](new_developer_guide.md) – Quickstart and platform setup.
