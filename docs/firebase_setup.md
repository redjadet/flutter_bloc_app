# Firebase Setup (Run the App with Firebase)

The repo includes a **placeholder** `lib/firebase_options.dart` so the project **compiles and runs** even when Firebase is not configured. In that case the app skips Firebase initialization and runs with Firebase-dependent features disabled (no crash, no login required).

To run this app **with** Firebase (Auth, Remote Config, Realtime Database, Crashlytics, etc.), add your own configuration as below. Platform config files (`google-services.json`, `GoogleService-Info.plist`) remain gitignored; `flutterfire configure` overwrites `lib/firebase_options.dart` with your project's options (do not commit that file if it contains real project IDs/keys).

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

From the **repository root**:

```bash
flutterfire configure
```

This will:

- Create a new Firebase project or let you select an existing one
- Register Android and iOS (and optionally macOS) apps with the correct package name / bundle ID from your Flutter project
- Download platform config files and generate Dart options
- Write the following (all currently gitignored):

| File | Location |
| ------ | ---------- |
| Android | `android/app/google-services.json` |
| iOS | `ios/Runner/GoogleService-Info.plist` |
| macOS | `macos/Runner/GoogleService-Info.plist` |
| Dart | `lib/firebase_options.dart` |

### 4. Run the app

```bash
flutter pub get
flutter run -t lib/main_dev.dart
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

4. **Add a macOS app** (optional, only if you run on macOS desktop)
   - Use the macOS bundle ID from your Xcode project.
   - Download `GoogleService-Info.plist` and place it at **`macos/Runner/GoogleService-Info.plist`**.

5. **Generate Dart options**
   - Either run `flutterfire configure` once (it will only update `lib/firebase_options.dart` and keep your existing platform files), or
   - Copy `lib/firebase_options.dart.sample` to `lib/firebase_options.dart` and replace placeholders with values from your Firebase project (project ID, app IDs, API keys, etc.). This is more error-prone; prefer the CLI.

6. **Run the app**

   ```bash
   flutter pub get
   flutter run -t lib/main_dev.dart
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
| **Firebase not initializing** | The app skips Firebase init when it detects placeholder values (e.g. `your-project-id`) in `lib/firebase_options.dart`. To use Firebase, run `flutterfire configure` so the file is replaced with your project's config. |
| **`flutterfire configure` fails** (e.g. "Failed to write Dart configuration file", "UnsupportedError not found in macOS", or **"FormatException: Unexpected character (at character 1)"**) | See [Workaround when FlutterFire CLI fails on macOS](#workaround-when-flutterfire-cli-fails-on-macos) below. The FormatException often means the CLI got non-JSON output from a Firebase command (e.g. login prompt or proxy/network issue). |
| **Missing google-services.json** | Run `flutterfire configure` or place the file at `android/app/google-services.json`. |
| **Missing GoogleService-Info.plist** | Run `flutterfire configure` or place the file at `ios/Runner/GoogleService-Info.plist`. |
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

- [Security & Secrets](security_and_secrets.md) – API keys (Hugging Face, Gemini, Maps); Firebase config is separate and not in `secrets.json`.
- [Deployment](deployment.md) – Store/CI and Firebase config file locations.
- [WalletConnect Auth Status](walletconnect_auth_status.md) – Demo Firebase setup for WalletConnect.
- [Developer Guide](new_developer_guide.md) – Quickstart and platform setup.
