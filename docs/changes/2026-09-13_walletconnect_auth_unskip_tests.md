# Unskip WalletConnect auth repository Firestore mock tests

## What landed

- Fixed mock stubs for `users/{uid}.get()` / `doc` precedence and used valid
  42-char Ethereum addresses so `getLinkedWalletAddress` succeeds
- Removed three `skip:` markers on upsert / getWalletUserProfile cases
- Second upsert test now passes a non-null `WalletUserProfile`

## Verification

```bash
cd apps/mobile && flutter test \
  test/features/walletconnect_auth/data/walletconnect_auth_repository_impl_test.dart
```
