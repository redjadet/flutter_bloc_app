# WalletConnect Auth Feature - Current Status & Production Readiness

## Overview

The WalletConnect Auth feature provides a demo implementation for wallet-based authentication using WalletConnect protocol. Users can connect their crypto wallets and link them to Firebase Auth accounts.

**Current Status**: ✅ **Demo-ready** (UI complete, mock data) | ⚠️ **Not production-ready** (real WalletConnect SDK not integrated)

### How to open (demo)

- Go to **Example page** (counter app bar or bottom nav → Example).
- Tap **“WalletConnect Auth (Demo)”**.
- Route: `/walletconnect-auth` (code: `lib/features/walletconnect_auth/`).

## What's Currently Implemented

### ✅ Complete Features

1. **UI Components**
   - ✅ `ConnectWalletButton` - Platform-adaptive button with loading state
   - ✅ `WalletAddressDisplay` - Displays wallet address in truncated format (`0x1234...5678`)
   - ✅ `WalletConnectAuthPage` - Main page with full flow (connect → link → display)
   - ✅ Error handling UI with dismissible error messages
   - ✅ Success indicators for linked wallets
   - ✅ Responsive design with proper spacing and theming

2. **State Management**
   - ✅ `WalletConnectAuthCubit` - Complete state management with error handling
   - ✅ `WalletConnectAuthState` (Freezed) - Immutable state with proper status tracking
   - ✅ Loading states for connection and linking operations
   - ✅ Error state handling with user-friendly messages

3. **Domain Layer**
   - ✅ `WalletAddress` - Value object with validation and truncation
   - ✅ `WalletConnectAuthRepository` - Clean contract interface
   - ✅ `WalletConnectException` - Proper exception types

4. **Data Layer**
   - ✅ `WalletConnectAuthRepositoryImpl` - Firebase integration complete
   - ✅ Firestore storage for wallet addresses (`/users/{uid}/walletAddress`)
   - ✅ Firebase Auth user creation (anonymous if needed)
   - ✅ User profile updates with wallet address
   - ✅ Error handling and logging

5. **Infrastructure**
   - ✅ Dependency injection setup
   - ✅ Route configuration (`/walletconnect-auth`)
   - ✅ Localization (en, tr, de, fr, es)
   - ✅ Tests (unit tests for domain, bloc tests for cubit)

### ⚠️ Mock/Placeholder Implementation

1. **WalletConnectService**
   - ⚠️ Returns hardcoded mock address: `0x1234567890123456789012345678901234567890`
   - ⚠️ Simulates 1-second connection delay
   - ⚠️ No actual WalletConnect SDK integration
   - ⚠️ No QR code generation or display
   - ⚠️ No real wallet session management

## Current Flow (Demo Mode)

```text
User clicks "Connect Wallet"
    ↓
WalletConnectService.connect() called
    ↓
1-second delay (simulated connection)
    ↓
Returns mock address: 0x1234567890123456789012345678901234567890
    ↓
Address displayed in UI
    ↓
User clicks "Link to Account"
    ↓
Wallet address stored in Firestore
    ↓
Firebase Auth user profile updated
    ↓
Success message displayed
```

## Plan for Proper Demo of the SDK (Not Production)

Goal: Replace the mock flow with a real WalletConnect SDK flow while keeping the scope demo‑friendly (single chain, basic QR, no long‑term session persistence).

### Scope (Demo‑Only)

- Real WalletConnect pairing and session approval
- QR code display for desktop → mobile wallets
- Extract and display a real wallet address
- Basic disconnect
- Single chain (Ethereum‑style address)

Out of scope for the demo: deep link handoff, multi‑chain support, session persistence across restarts, signature verification.

### Phase 1 — SDK Initialization & Pairing

#### Phase 1: Affected files

- `lib/features/walletconnect_auth/data/walletconnect_service.dart`

#### Phase 1: Tasks

- Initialize the WalletConnect client with project ID + app metadata.
- Implement pairing and obtain the pairing URI.
- Surface the URI to UI (return a small data model or stream).

#### Phase 1: Acceptance

- Pairing URI is created and logged (dev only).
- No hardcoded wallet address remains in service.

### Phase 2 — QR UI + Session Approval

#### Phase 2: Affected files

- `lib/features/walletconnect_auth/presentation/pages/walletconnect_auth_page.dart`
- `lib/features/walletconnect_auth/presentation/widgets/qr_code_display.dart` (new)

#### Phase 2: Tasks

- Add QR widget that renders the pairing URI.
- Wait for session approval and extract the first account address.
- Update cubit state with real address, keep error handling.

#### Phase 2: Acceptance

- QR shown when user taps Connect.
- After approving in a wallet, a real address appears in UI.

### Phase 3 — Disconnect + Basic Cleanup

#### Phase 3: Affected files

- `lib/features/walletconnect_auth/data/walletconnect_service.dart`
- `lib/features/walletconnect_auth/presentation/cubit/walletconnect_auth_cubit.dart`

#### Phase 3: Tasks

- Implement session disconnect via SDK.
- Ensure local state clears on disconnect.

#### Phase 3: Acceptance

- Disconnect clears address in UI and SDK session ends.

### Phase 4 — Minimal Demo Hardenings

#### Phase 4: Affected files

- `lib/features/walletconnect_auth/data/walletconnect_service.dart`
- `lib/features/walletconnect_auth/presentation/pages/walletconnect_auth_page.dart`

#### Phase 4: Tasks

- Add simple timeout for session approval.
- Handle user rejection or timeout with a localized error message.
- Keep fallback repository working without Firebase.

#### Phase 4: Acceptance

- Timeout or rejection shows a user‑friendly error.
- Demo still runs when Firebase is not configured.

### Validation Checklist (Demo)

- [ ] Pairing URI generated from SDK (no mock address).
- [ ] QR renders on the Connect screen.
- [ ] Wallet approval returns a real address.
- [ ] Disconnect removes active session.
- [ ] Errors are localized and shown in UI.

### Notes for Implementation

- Keep a single‑chain assumption for the demo to avoid chain selection UI.
- Use existing cubit error handling and `context.cubit<T>()` access pattern.
- Avoid heavy work in `build()`; any subscriptions should be in init or service.

## Potential WalletConnect Flutter Packages & API Notes (Discovery)

This section summarizes candidate SDKs/APIs and the minimum flows they enable for a real demo.

### Reown AppKit (dApp‑side, UI‑first)

**Package**: `reown_appkit`
**Use case**: dApp integration with built‑in modal UI.

**Key API surface (from docs)**:

- `ReownAppKitModal` constructor requires `context`, `projectId`, and `PairingMetadata` with `Redirect` (native/universal/linkMode).
- `await _appKitModal.init()` to initialize.
- Built‑in UI buttons: `AppKitModalConnectButton`, `AppKitModalNetworkSelectButton`, `AppKitModalAccountButton`, `AppKitModalAddressButton`, `AppKitModalBalanceButton`.
- `openModalView()` can open specific pages (QR code, network selection, all wallets).
citeturn2view0

**Implementation implications**:

- Fits the current demo best if you want a working QR + wallet picker quickly.
- Requires project ID + redirect configuration for deep links.
citeturn2view0

### Reown WalletKit (wallet‑side, low‑level)

**Package**: `reown_walletkit`
**Use case**: building a wallet that connects to dApps (not a dApp).

**Key API surface (from pub.dev readme)**:

- Initialize via `ReownWalletKit.createInstance(projectId, PairingMetadata)`.
- Pair with dApp via `walletKit.pair(uri: Uri.parse(wcUri))`.
- Session lifecycle: `onSessionProposal`, `approveSession`, `rejectSession`, `updateSession`, `extendSession`, `disconnectSession`, `getActiveSessions`.
- Requests: `registerRequestHandler`, `onSessionRequest`, `respondSessionRequest`.
- Events: `registerEventEmitter`, `emitSessionEvent`, `onSessionDelete`, `onSessionExpire`.
citeturn3view0

**Implementation implications**:

- Use only if this app is acting as a wallet. For the demo dApp flow, AppKit is the better fit.
citeturn3view0

### walletconnect_flutter_v2 (deprecated)

**Package**: `walletconnect_flutter_v2`
**Status**: Marked as no longer maintained; upgrade to Reown packages.
citeturn4view0

**Key API surface (from docs)**:

- `Web3App.createInstance(...)` (AuthClient deprecated; SignClient preferred).
- `connect(...)` returns a `ConnectResponse` with `uri` (QR/deeplink) and `session.future`.
- `request(...)` sends JSON‑RPC requests after session approval.
citeturn4view0

**Implementation implications**:

- Useful only for reference if you keep the older stack; not recommended for new demo work.
citeturn4view0

### walletconnect_dart (legacy v1)

**Package**: `walletconnect_dart`
**Status**: Legacy WalletConnect v1 community SDK.

**Key API surface (from docs)**:

- Create connector: `WalletConnect(bridge, clientMeta)` and `createSession(...)` with `onDisplayUri`.
- Subscribe to `connect`, `session_update`, `disconnect`.
- Wallet‑side: `approveSession`, `rejectSession`, `updateSession`, `killSession`.
citeturn5view0

**Implementation implications**:

- Not suitable for v2 WalletConnect demo; included only for historical reference.
citeturn5view0

### walletconnect_dart_v2_i (community v2 fork)

**Package**: `walletconnect_dart_v2_i`
**Status**: Dart v2 fork adapted from the WalletConnectFlutterV2 implementation.
citeturn0search1

**Implementation implications**:

- Consider only if you need a pure‑Dart v2 fork; expect additional setup (e.g., platform permissions).
citeturn0search1

### Recommendation for This Demo

For a dApp demo with QR + connect + address display, the most direct path is `reown_appkit` with `ReownAppKitModal` and the built‑in connect/QR screens.
citeturn2view0

## What Needs to Be Done for Production

### 1. Integrate Real WalletConnect SDK

**File**: `lib/features/walletconnect_auth/data/walletconnect_service.dart`

**Current State**: Uses placeholder `_client = <String, dynamic>{}`

**Required Changes**:

1. **Initialize WalletConnect Client**

   ```dart
   // Replace placeholder initialization
   _client = WalletConnectV2();
   await _client!.init(
     projectId: _projectId, // Get from config/secrets
     appMetadata: _createAppMetadata(),
   );
   ```

2. **Implement Real Connection Flow**
   - Generate pairing URI using WalletConnect SDK
   - Display QR code for mobile wallets
   - Handle deep linking for mobile-to-mobile connections
   - Listen for session approval/rejection events
   - Extract actual wallet address from approved session

3. **Session Management**
   - Store active sessions
   - Handle session disconnection
   - Reconnect to existing sessions
   - Handle session expiration

4. **Error Handling**
   - Handle wallet rejection
   - Handle connection timeouts
   - Handle network errors
   - Handle unsupported chains

### 2. QR Code Display

**New Component Needed**: `lib/features/walletconnect_auth/presentation/widgets/qr_code_display.dart`

**Requirements**:

- Display QR code generated from WalletConnect pairing URI
- Show connection instructions
- Handle QR code scanning errors
- Auto-refresh if connection times out
- Platform-adaptive styling

**Dependencies**:

- `qr_flutter` or `qr_code` package for QR code generation
- WalletConnect SDK pairing URI

### 3. Deep Linking Support

**Requirements**:

- Handle WalletConnect deep links (`wc://` or custom scheme)
- Parse WalletConnect URI from deep links
- Auto-connect when app opens via deep link
- Handle mobile-to-mobile wallet connections

**Files to Modify**:

- `lib/app/router/deep_link_*.dart` - Add WalletConnect deep link handling
- `lib/features/walletconnect_auth/data/walletconnect_service.dart` - Handle deep link URIs

### 4. Configuration

**Required Setup**:

1. **WalletConnect Project ID**
   - Get project ID from [WalletConnect Cloud](https://cloud.walletconnect.com/)
   - Store in `assets/config/secrets.json` or via `--dart-define`
   - Update `WalletConnectService._defaultProjectId`

2. **App Metadata**
   - Update `_createAppMetadata()` with actual app info:
     - App name
     - App URL
     - App icons (proper URLs)
     - App description

3. **Supported Chains**
   - Configure which blockchains to support (Ethereum, Polygon, etc.)
   - Define chain IDs and RPC endpoints

### 5. Session Persistence

**Requirements**:

- Persist active WalletConnect sessions
- Restore sessions on app restart
- Handle session expiration gracefully
- Clear expired sessions

**Implementation**:

- Store sessions in Hive or SharedPreferences
- Implement session restoration in `WalletConnectService.initialize()`
- Add session expiry checks

### 6. Chain Selection (Optional but Recommended)

**Requirements**:

- Allow users to select which blockchain to connect to
- Support multiple chains simultaneously
- Display chain information in UI
- Handle chain switching

### 7. Security Considerations

**Required**:

- ✅ Wallet addresses validated (already implemented)
- ⚠️ Verify wallet signatures for authentication
- ⚠️ Implement nonce-based authentication
- ⚠️ Add rate limiting for connection attempts
- ⚠️ Secure storage for WalletConnect project credentials

### 8. Testing

**Additional Tests Needed**:

- Integration tests with WalletConnect SDK
- QR code display tests
- Deep link handling tests
- Session persistence tests
- Error scenario tests (rejection, timeout, network errors)

## Implementation Checklist

### Phase 1: SDK Integration (Critical)

- [ ] Add WalletConnect project ID to configuration
- [ ] Initialize real WalletConnect client in `WalletConnectService`
- [ ] Implement pairing URI generation
- [ ] Implement session approval handling
- [ ] Extract wallet address from approved session
- [ ] Replace mock `_waitForSession()` with real session flow

### Phase 2: QR Code & UI (Critical)

- [ ] Add QR code generation package (`qr_flutter`)
- [ ] Create `QrCodeDisplay` widget
- [ ] Integrate QR code into connection flow
- [ ] Add connection instructions/help text
- [ ] Handle QR code refresh/timeout

### Phase 3: Deep Linking (Important)

- [ ] Configure app deep link schemes
- [ ] Add WalletConnect URI parsing
- [ ] Handle deep link connections
- [ ] Test mobile-to-mobile connections

### Phase 4: Session Management (Important)

- [ ] Implement session persistence
- [ ] Add session restoration on app start
- [ ] Handle session expiration
- [ ] Add session cleanup

### Phase 5: Error Handling & UX (Important)

- [ ] Improve error messages for wallet rejection
- [ ] Add connection timeout handling
- [ ] Add retry mechanisms
- [ ] Improve loading states

### Phase 6: Security & Production (Recommended)

- [ ] Implement wallet signature verification
- [ ] Add nonce-based authentication
- [ ] Add rate limiting
- [ ] Security audit of wallet connection flow

## Technical Details

### WalletConnect SDK Integration Example

```dart
// Example structure (actual implementation depends on wallet_connect_v2 package API)
Future<WalletAddress> connect() async {
  // 1. Initialize client
  await _client.init(projectId: _projectId, appMetadata: _createAppMetadata());

  // 2. Create pairing
  final pairing = await _client.pair();
  final uri = pairing.uri;

  // 3. Display QR code or deep link
  await _showConnectionUI(uri);

  // 4. Wait for approval
  final session = await _waitForSessionApproval(pairing.topic);

  // 5. Extract wallet address
  final accounts = session.accounts;
  final address = accounts.first; // First account from wallet

  return WalletAddress(address);
}
```

### Firestore Structure

```text
/users/{userId}/
  walletAddress: "0x..." (string)
  connectedAt: timestamp
  chainId: 1 (optional, for multi-chain support)
```

### Dependencies to Add

```yaml
dependencies:
  wallet_connect_v2: ^1.0.0  # Already added
  qr_flutter: ^4.1.0          # For QR code generation
```

## Required Firebase Setup (for “Link to Account”)

If you see **“Failed to link wallet to Firebase user”**, check the following in your Firebase project.

### 1. Enable Anonymous sign-in

Linking creates an anonymous user when none exists.

1. Open [Firebase Console](https://console.firebase.google.com/) → your project.
2. Go to **Authentication** → **Sign-in method**.
3. Enable **Anonymous**.

### 2. Firestore security rules

The app writes the wallet to `users/{userId}`. Rules must allow the signed-in user to write their own document.

**Example rules** (Firebase Console → Firestore → Rules):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Deploy rules (e.g. `firebase deploy --only firestore:rules` if you use the Firebase CLI).

After enabling Anonymous auth and updating Firestore rules, “Link to Account” should succeed. The app will now show the underlying error (e.g. permission-denied or auth code) in the message if something still fails.

## Known Limitations

1. **Mock Data**: Currently returns hardcoded wallet address
2. **No Real Connection**: No actual wallet communication
3. **No QR Code**: QR code display not implemented
4. **No Deep Linking**: Deep link handling not implemented
5. **No Session Persistence**: Sessions don't persist across app restarts
6. **Single Chain**: Only supports Ethereum-style addresses (no chain selection)

## Demo vs Production

| Feature | Demo | Production |
| --- | --- | --- |
| Connect Wallet Button | ✅ Works | ✅ Works |
| Display Wallet Address | ✅ Shows mock | ✅ Shows real |
| Link to Firebase | ✅ Works | ✅ Works |
| Real Wallet Connection | ❌ Mock only | ⚠️ Needs SDK |
| QR Code Display | ❌ Not implemented | ⚠️ Needs implementation |
| Deep Linking | ❌ Not implemented | ⚠️ Needs implementation |
| Session Persistence | ❌ Not implemented | ⚠️ Needs implementation |
| Error Handling | ✅ Basic | ⚠️ Needs enhancement |

## Next Steps

1. **For Demo**: Current implementation is sufficient - shows UI flow with mock data
2. **For Production**:
   - Start with Phase 1 (SDK Integration) - most critical
   - Then Phase 2 (QR Code) - required for user experience
   - Then Phase 3-6 based on priority

## Resources

- [WalletConnect Documentation](https://docs.walletconnect.com/)
- [WalletConnect Cloud](https://cloud.walletconnect.com/) - Get project ID
- [wallet_connect_v2 Package](https://pub.dev/packages/wallet_connect_v2)
- [QR Flutter Package](https://pub.dev/packages/qr_flutter)

## Related Files

- `lib/features/walletconnect_auth/` - Feature implementation
- `lib/features/example/presentation/widgets/example_page_body.dart` - Entry-point button (“WalletConnect Auth (Demo)”)
- `lib/core/di/register_walletconnect_auth_services.dart` - DI setup
- `lib/app/router/route_groups.dart` - Route definition
- `test/features/walletconnect_auth/` - Tests

## See also

- [Firebase UI Auth overflow fix](firebase_ui_auth_overflow_fix.md) – If the **profile screen** shows a RenderFlex overflow after linking a wallet (long display name), apply the fix described there.
