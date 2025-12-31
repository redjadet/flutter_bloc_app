# UI/UX + Responsive/Adaptive Review

**Scope:** Mobile-first UI/UX behavior (iOS + Android), responsive layout helpers, platform-adaptive widgets, accessibility (text scaling, safe areas), and representative presentation screens.

**Review Focus:** iOS gesture bars, Android cutouts, keyboard handling, text scaling, and platform-specific UI patterns.

## Strengths Observed

- **Responsive System:** Centralized spacing, layout, typography, and grid helpers provide consistent responsive behavior. See `lib/shared/extensions/responsive.dart` and `lib/shared/extensions/responsive/`.
- **Shared Layout Components:** Common page shell and app bar promote consistent navigation and structure. See `lib/shared/widgets/common_page_layout.dart` and `lib/shared/widgets/common_app_bar.dart`.
- **Platform Adaptation:** Platform-aware buttons and dialog actions exist and are used in multiple features. See `lib/shared/utils/platform_adaptive.dart` and `lib/shared/widgets/common_empty_state.dart`.
- **Good Patterns:** Several screens demonstrate proper safe-area handling and scroll behavior (e.g., `calculator_page.dart` uses `SafeArea` with keyboard insets). See `lib/features/calculator/presentation/pages/calculator_page.dart`.
- **Platform-Aware Loading:** `CommonLoadingButton` correctly uses `CupertinoActivityIndicator` on iOS and `CircularProgressIndicator` on Android. See `lib/shared/widgets/common_loading_widget.dart`.

## Findings (Mobile UI/UX + Responsive/Adaptive)

### Critical Issues (High Priority)

1. **Safe-area padding is not applied in the common page shell.** ✅ *Resolved*
   ~~`CommonPageLayout` wraps the body in fixed horizontal/vertical padding, but does not include safe-area insets or keyboard insets. On modern iOS/Android devices with gesture bars and cutouts, this can cause content to sit under system UI and reduce tap reliability. The responsive helper `pagePadding` already includes `bottomInset` and is unused.~~
   - `lib/shared/widgets/common_page_layout.dart` - *Now uses safe-area and keyboard insets*
   - `lib/shared/extensions/responsive/responsive_layout.dart`
   - **Status:** ✅ Implemented - `_ResponsiveBody` now applies `context.bottomInset` and `MediaQuery.viewInsetsOf(context).bottom` for keyboard-aware padding.

2. **Absolute-positioned logged-out layout risks overflow on text scale and short heights.** ✅ *Resolved*
   ~~The logged-out screen uses a fixed base size and `Positioned` widgets scaled by width/height. This may not reflow on large text sizes, small height devices, or dynamic type on iOS, and can reduce tap target reliability on Android when the keyboard appears.~~
   - `lib/features/auth/presentation/widgets/logged_out_page_body.dart` - *Refactored to use Column layout*
   - `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart`
   - **Status:** ✅ Implemented - Layout now uses reflowing `Column` with scroll fallback, respects text scaling, and handles compact heights gracefully.

### Important Issues (Medium Priority)

1. **Hard-coded colors reduce theme adaptiveness and dark-mode UX.**
   Several widgets fix text and background colors to black/white/gray, which can be harsh in dark mode and inconsistent with iOS/Android system themes. This is especially noticeable in profile and error surfaces.
   - `lib/features/profile/presentation/pages/profile_page.dart` (Colors.white, Colors.black)
   - `lib/features/profile/presentation/widgets/profile_header.dart` (Colors.grey[300], Colors.black)
   - `lib/features/profile/presentation/widgets/profile_action_buttons.dart` (Colors.black, Colors.white)
   - `lib/shared/widgets/common_error_view.dart` (Colors.black54, Colors.black)
   - `lib/features/search/presentation/widgets/search_results_grid.dart` (Colors.grey[300], Colors.black54)
   - `lib/features/auth/presentation/widgets/logged_out_*.dart` (multiple hard-coded colors)
   - `lib/features/chat/presentation/widgets/chat_*.dart` (Colors.white, Colors.grey)
   - **Impact:** Poor dark mode experience, inconsistent with Material 3 color scheme, reduced accessibility contrast.

2. **Hard-coded UI strings bypass localization.**
   Multiple screens and shared widgets include English-only strings, which weakens UX for non-default locales and consistency with the rest of the app's localization strategy.
   - `lib/features/search/presentation/widgets/search_text_field.dart` ("Search...")
   - `lib/shared/widgets/common_form_field.dart` ("Search..." in `CommonSearchField`)
   - `lib/shared/widgets/common_error_view.dart` ("TRY AGAIN" in `CommonRetryButton`)
   - `lib/features/profile/presentation/pages/profile_page.dart` (various strings)
   - `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart` (button labels)
   - `lib/shared/widgets/sync_status_banner.dart` ("Retry")
   - **Impact:** Poor UX for users in TR, DE, FR, ES locales; inconsistent with app's localization.

3. **Fixed typography metrics can strain layouts at large text scales.**
   Several widgets use fixed font sizes, letter spacing, and line heights tuned for a base design size. While Flutter scales text by default, these fixed metrics and tight layouts can still overflow at large accessibility sizes, especially on iOS Dynamic Type.
   - Example: `lib/features/profile/presentation/widgets/profile_header.dart` uses fixed `fontSize`, `letterSpacing`, and `height` values
   - **Impact:** Overflow and clipped text at 1.3+ text scale on iOS/Android.

### Enhancement Opportunities (Low Priority)

1. **Custom retry button bypasses adaptive button patterns.**
   `CommonRetryButton` uses a custom `InkWell` instead of the platform-adaptive button helpers, which can lead to inconsistent platform styling and accessibility semantics on iOS/Android.
   - `lib/shared/widgets/common_error_view.dart`
   - **Impact:** Inconsistent button styling, potential accessibility issues, doesn't match platform conventions.

2. **Loading indicator is Material-only in standalone widget.**
   `CommonLoadingWidget` always uses `CircularProgressIndicator`, which does not match iOS conventions. However, `CommonLoadingButton` correctly uses platform-adaptive indicators. This inconsistency can make loading states feel non-native on iOS.
   - `lib/shared/widgets/common_loading_widget.dart` (uses `CircularProgressIndicator` only)
   - **Impact:** Non-native feel on iOS, inconsistent with `CommonLoadingButton` pattern.

## Action Checklist

### High Priority

#### 1. Shell: Apply Safe-Area-Aware Padding in `CommonPageLayout`

**Owner:** Mobile UI
**Effort:** S (0.5-1 day)
**Status:** ✅
**Files:** `lib/shared/widgets/common_page_layout.dart`, `lib/shared/extensions/responsive/responsive_layout.dart`

**Problem:** Shared layout padding ignores safe-area and keyboard insets, so content can be obscured by iOS/Android gesture bars and device cutouts.

**Solution:**

1. Update `_ResponsiveBody` to use `context.pagePadding` or wrap `Padding` with `SafeArea` and include `viewInsets.bottom` where needed.
2. Ensure the common shell still respects `contentMaxWidth` and existing spacing helpers.
3. Check any pages using custom `Scaffold` body padding for duplication (avoid double-insets).

**Acceptance Criteria:**

- [x] `CommonPageLayout` content never overlaps system gesture areas on iOS/Android.
- [x] Keyboard does not cover bottom content on forms using `CommonPageLayout`.
- [x] Test on iPhone X+ (notch/gesture bar) and Android devices with cutouts.
- [x] Verify existing pages (settings, GraphQL demo, etc.) still render correctly.

**Current Implementation:**

- `_ResponsiveBody` now applies safe-area and keyboard-aware padding by combining:
  - `context.bottomInset` (safe-area bottom inset)
  - `MediaQuery.viewInsetsOf(context).bottom` (keyboard height)
  - Uses `AnimatedPadding` for smooth transitions when keyboard appears/disappears
  - Maintains `contentMaxWidth` constraint and existing spacing helpers

**Test Requirements:**

- Widget test: add safe-area inset coverage in `test/shared/widgets/common_page_layout_test.dart` (pending).
- Manual: iOS simulator + Android emulator with gesture navigation and keyboard visible (verified).
- Reference: `lib/features/calculator/presentation/pages/calculator_page.dart` shows good pattern.

**Verification:**

```bash
flutter test test/shared/widgets/common_page_layout_test.dart
```

---

#### 2. Auth: Refactor Logged-Out Screen for Text Scale and Compact Heights

**Owner:** Mobile UI
**Effort:** M (1-2 days)
**Status:** ✅
**Files:** `lib/features/auth/presentation/widgets/logged_out_page_body.dart`, `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart`

**Problem:** Fixed `Positioned` layout doesn't reflow on large text scales or compact devices, reducing accessibility and tap reliability.

**Solution:**

1. Replace fixed `Positioned` layout with a reflowing `Column` and a scroll fallback inside a `Stack` background.
2. Use `SingleChildScrollView` for overflow protection.
3. Ensure minimum tap target sizes (44x44 iOS, 48x48 Android) are maintained.
4. Test with text scale 1.3+ and compact height devices.

**Current Implementation:**

- Layout now uses a `Column` with scaled gaps and a scroll fallback.
- Background layer remains in a `Stack`, content is reflowing and centered.
- Logged-out widgets no longer rely on `Positioned` offsets.
- Vertical gaps are distributed based on available height to avoid overflow.
- Background image height now ends above the action buttons with a fixed gap.

**Acceptance Criteria:**

- [x] No overflow at text scale 1.3+ on iOS/Android.
- [x] Content scrolls gracefully on compact height devices.
- [x] All interactive elements meet minimum tap target sizes.
- [x] Layout remains visually balanced across device sizes.

**Test Requirements:**

- Widget test: use existing `test/features/auth/presentation/pages/logged_out_page_test.dart` to validate layout (basic coverage exists).
- Manual: largest text size on iOS/Android, compact height devices, keyboard visible (verified).

**Verification:**

```bash
flutter test test/features/auth/presentation/pages/logged_out_page_test.dart
```

---

### Medium Priority

#### 3. Theme: Replace Hard-Coded Colors with Theme-Aware Colors

**Owner:** Design Systems
**Effort:** M (1-2 days)
**Status:** ⬜
**Files:** Multiple (see Important Issues #1: Hard-coded colors)

**Problem:** Hard-coded black/white/gray colors break dark mode and reduce theme consistency.

**Solution:**

1. Replace `Colors.black`, `Colors.white`, `Colors.grey` with `Theme.of(context).colorScheme` equivalents:
   - Text: `colorScheme.onSurface`, `colorScheme.onSurfaceVariant`
   - Backgrounds: `colorScheme.surface`, `colorScheme.surfaceContainerHighest`
   - Borders: `colorScheme.outline`, `colorScheme.outlineVariant`
2. Review contrast ratios for accessibility (WCAG AA minimum).
3. Test in both light and dark themes on iOS/Android.

**Acceptance Criteria:**

- [ ] All hard-coded colors replaced with theme colors.
- [ ] Dark mode looks consistent and readable.
- [ ] Contrast ratios meet WCAG AA standards.
- [ ] Colors adapt correctly to Material 3 color scheme.

**Test Requirements:**

- Update profile/search widget tests to assert theme-aware colors where feasible.
- Manual: dark mode on iOS/Android for profile and search screens.

**Verification:**

```bash
flutter test test/features/profile/presentation/profile_page_test.dart
flutter test test/features/search/presentation/pages/search_page_test.dart
```

---

#### 4. Localization: Move Hard-Coded Strings to `AppLocalizations`

**Owner:** Localization
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:** Multiple (see Important Issues #2: Hard-coded UI strings)

**Problem:** English-only strings break localization for TR, DE, FR, ES locales.

**Solution:**

1. Add missing strings to `lib/l10n/app_*.arb` files (en, tr, de, fr, es).
2. Update widgets to use `context.l10n.*` instead of hard-coded strings.
3. Verify all locales have translations.

**Acceptance Criteria:**

- [ ] No hard-coded user-facing strings remain.
- [ ] All strings added to ARB files for all supported locales.
- [ ] Test app in each locale (TR, DE, FR, ES) to verify translations.

**Files to Update:**

- `lib/features/search/presentation/widgets/search_text_field.dart` → add new localized hint key (e.g., `searchHint`).
- `lib/shared/widgets/common_form_field.dart` → reuse the same localized hint key.
- `lib/shared/widgets/common_error_view.dart` → use existing `appInfoRetryButtonLabel` or add new `retryButton` key.
- `lib/shared/widgets/sync_status_banner.dart` → reuse localized retry label key.
- Profile/auth widgets → add missing labels to ARB files (en, tr, de, fr, es).

**Test Requirements:**

- Run `flutter gen-l10n` after adding ARB entries and update widget tests that assert text.
- Verify all locales (en, tr, de, fr, es) have translations.

**Verification:**

```bash
# After adding ARB entries
flutter gen-l10n
flutter test test/features/profile/presentation/profile_page_test.dart
flutter test test/features/search/presentation/pages/search_page_test.dart
```

---

#### 5. Accessibility: Validate Layouts at Large Text Scale

**Owner:** Accessibility
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:** Text-heavy widgets (especially profile, search, error views)

**Problem:** Fixed typography metrics and tight layouts can overflow at large text scales even though Flutter scales text by default.

**Solution:**

1. Review text-heavy widgets with fixed metrics (font size, height, letter spacing).
2. Allow vertical reflow and wrap where needed; avoid tight fixed heights.
3. Test with large text scales (1.3+) on iOS/Android.

**Acceptance Criteria:**

- [ ] No overflow at 1.3+ text scale on profile, search, error, and auth screens.
- [ ] Text remains readable and buttons keep minimum tap sizes.

**Test Requirements:**

- Manual: iOS Dynamic Type (Largest), Android font size (Largest).
- Automated: smoke test exists at `test/shared/widgets/text_scaling_smoke_test.dart` (covers 1.3x text scale for `CommonPageLayout`).

**Verification:**

```bash
flutter test test/shared/widgets/text_scaling_smoke_test.dart
# Expand coverage to profile, search, error views as needed
```

---

### Low Priority

#### 6. Components: Align Retry Button with Platform-Adaptive Patterns

**Owner:** Component Library
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:** `lib/shared/widgets/common_error_view.dart`

**Problem:** Custom `InkWell` button doesn't match platform conventions or use adaptive helpers.

**Solution:**

1. Rebuild `CommonRetryButton` using `PlatformAdaptive.filledButton` or `PlatformAdaptive.button`.
2. Use localized string from `AppLocalizations` (e.g., `appInfoRetryButtonLabel`).
3. Ensure focus/hover/disabled states follow platform conventions.

**Acceptance Criteria:**

- [ ] Retry button uses platform-adaptive styling.
- [ ] Button matches iOS/Android native button appearance.
- [ ] Accessibility semantics are correct.

**Test Requirements:**

- Widget test: validate button renders in `test/shared/widgets/common_error_view_test.dart`.

**Verification:**

```bash
flutter test test/shared/widgets/common_error_view_test.dart
```

---

#### 7. Components: Make Loading Widget Platform-Adaptive

**Owner:** Component Library
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:** `lib/shared/widgets/common_loading_widget.dart`

**Problem:** `CommonLoadingWidget` always uses `CircularProgressIndicator`, inconsistent with iOS conventions and `CommonLoadingButton`.

**Solution:**

1. Update `CommonLoadingWidget` to use `PlatformAdaptive.isCupertino(context)` check.
2. Use `CupertinoActivityIndicator` on iOS, `CircularProgressIndicator` on Android.
3. Match the pattern used in `CommonLoadingButton`.

**Acceptance Criteria:**

- [ ] iOS uses Cupertino indicator; Android uses Material indicator.
- [ ] Consistent with `CommonLoadingButton` pattern.
- [ ] No visual regressions in existing screens.

**Test Requirements:**

- Widget test: `test/shared/widgets/common_loading_widget_test.dart`.

**Verification:**

```bash
flutter test test/shared/widgets/common_loading_widget_test.dart
```

---

## Testing Strategy

### Platform-Specific Testing

**iOS:**

- Test on iPhone X+ (notch/gesture bar)
- Test with Dynamic Type (Settings → Display & Brightness → Text Size)
- Test in dark mode
- Test with keyboard visible/hidden
- Verify safe area insets are respected

**Android:**

- Test on devices with cutouts (Pixel 6, etc.)
- Test with large font sizes (Settings → Accessibility → Font size)
- Test in dark theme
- Test with keyboard visible/hidden
- Verify system UI insets are respected

### Accessibility Testing

- Text scale: 1.3+ (iOS/Android largest settings)
- Screen readers: VoiceOver (iOS), TalkBack (Android)
- Contrast: Use accessibility inspector to verify WCAG AA compliance
- Tap targets: Minimum 44x44 (iOS), 48x48 (Android)

### Device Coverage

- **iOS:** iPhone SE (compact), iPhone 14 Pro (notch), iPad Pro (tablet)
- **Android:** Pixel 6 (cutout), various screen sizes
- **Orientation:** Portrait and landscape where applicable

---

## Implementation Notes

### Dependencies

- **Item 1** (Safe-area padding) should be done first as it affects all pages using `CommonPageLayout`.
- **Item 3** (Theme colors) and **Item 4** (Localization) can be done in parallel.
- **Item 2** (Logged-out screen) is independent but high priority for accessibility.

### Good Patterns to Reference

- **Safe Area:** `lib/features/calculator/presentation/pages/calculator_page.dart` (uses `SafeArea` with keyboard insets)
- **Platform-Adaptive Loading:** `lib/shared/widgets/common_loading_widget.dart` (`CommonLoadingButton` shows correct pattern)
- **Theme Colors:** `lib/shared/widgets/message_bubble.dart` (uses `colorScheme` correctly)
- **Text Scaling:** `lib/shared/widgets/message_bubble.dart` (uses `MediaQuery.textScalerOf(context)`)

### Verification Commands

After implementing changes:

```bash
# Run validation checks
./bin/checklist

# Test on iOS simulator
flutter run -d ios

# Test on Android device/emulator
flutter run -d android

# Verify no regressions
flutter test
```

## Ready-To-Start Notes

### Constraints to Follow

- Avoid side effects in `build()` methods; use `initState` for setup.
- Use `PlatformAdaptive` button and dialog helpers; avoid raw Material buttons.
- Use `context` responsive helpers for spacing and sizing (no ad-hoc constants).
- Keep UI changes in presentation layer; avoid direct `GetIt` usage in widgets.

### Definition of Done

- All applicable checklist items are ✅ with updated acceptance criteria.
- Related widget tests updated or added with existing paths.
- Manual mobile checks completed for safe areas, keyboard, and text scaling.

---

## Progress Tracking

Update status emoji (⬜ 🟡 ✅ ⏸️) in this document as items progress:

- ⬜ = Not started
- 🟡 = In progress
- ✅ = Completed
- ⏸️ = Blocked/Paused
