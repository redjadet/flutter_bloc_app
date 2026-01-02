# Feature Overview

This document provides a comprehensive catalog of features implemented in this Flutter app, with links to deeper technical references where applicable.

> **Quick Links**: [Architecture Details](architecture_details.md) | [Testing Overview](testing_overview.md) | [UI/UX Guidelines](ui_ux_responsive_review.md)

## Highlights

This application demonstrates production-grade Flutter development with:

- **Clean Architecture** - Domain → Data → Presentation separation with dependency injection and testable boundaries
- **Offline-First Repositories** - Background sync, retries, and cache-first reads for resilient data access
- **Responsive/Adaptive UI** - Platform-aware components and shared design system for consistent cross-platform experience
- **Robust Quality Gates** - Formatting, analysis, validation scripts, and comprehensive test coverage
- **Security-Minded Foundations** - Encrypted storage, biometric gating, and secure authentication routing

## What This App Demonstrates

### Architecture

- **Repository Pattern** - Abstracted data access with clear contracts and implementations
- **Dependency Injection Composition Root** - Centralized DI via `get_it` with lazy singleton pattern
- **Flutter-Agnostic Domain** - Domain layer remains pure Dart, enabling testability and platform independence

### Offline-First

- **Pending Sync Queues** - Operations queued when offline, processed when connectivity returns
- **Cache-First Reads** - Local data served immediately, remote updates in background
- **Background Flushing** - Automatic sync coordination with configurable intervals

### UI/UX

- **Material 3 + Cupertino Adaptive Widgets** - Platform-native feel on iOS and Android
- **Text Scaling Support** - Handles accessibility text scaling (1.3+) without layout breaks
- **Safe-Area Handling** - Proper insets for notches, keyboards, and device cutouts
- **Responsive Layout Helpers** - Shared spacing, typography, and grid utilities

### Resilience

- **Error Mapping** - Domain failures translate to user-friendly messages
- **Retries** - Configurable retry logic with exponential backoff
- **Guarded Async Flows** - Lifecycle safety checks prevent crashes during async operations
- **Lifecycle Safety** - Context mounted checks, cubit disposal guards, stream cleanup

### Performance

- **BlocSelector** - Granular rebuilds for optimal performance
- **Repaint Isolation** - `RepaintBoundary` widgets prevent unnecessary repaints
- **Responsive Layout Helpers** - Efficient grid calculations and layout constraints
- **Lazy Loading Optimizations** - Deferred imports for heavy features, reducing initial bundle size (see [Lazy Loading Analysis](../analysis/lazy_loading_late_review.md))

## Core Counter Feature

- Auto-decrement timer (never below zero)
- Live countdown indicator
- Encrypted persistence with Hive + migrations
- Biometric gating for sensitive actions

## UI/UX Excellence

- Responsive design via shared spacing/typography helpers
- Platform-adaptive widgets (`PlatformAdaptive.*`) for iOS/Android parity
- Theme-aware colors using `Theme.of(context).colorScheme`
- Safe area + keyboard handling via `CommonPageLayout`
- Text scaling support (1.3+), minimum tap targets
- Localization for EN/TR/DE/FR/ES using `context.l10n.*`
- Skeleton loading and shimmer effects
- Cached remote images with `CachedNetworkImageWidget`

## Authentication & Security

- Firebase Auth with email/password, Google, and anonymous sessions
- Biometric authentication support
- Secure storage (Keychain/Keystore-backed)
- Environment-based secret configuration
- Details: `docs/authentication.md`

## Data & Networking

- Offline-first by default with sync queues and cache-first reads
- REST, GraphQL, WebSocket, and Firebase integrations
- Remote config with cache + version tracking
- Offline-first feature notes: `docs/offline_first/adoption_guide.md`

## Maps & Location

- Google Maps with curated location list
- Apple Maps fallback when Google keys are unavailable
- Runtime map controls (type switching, marker selection)

## Chat & Communication

- AI chat via Hugging Face Inference API
- Offline queueing and sync for chat messages
- Cached local history with encryption
- Chat offline-first details: `docs/offline_first/chat.md`

## Payment Calculator

- iOS-style keypad
- Expression history
- Tax/tip presets
- Payment summary screen

## Advanced UI Features

- Whiteboard with `CustomPainter`:
  - Touch/pointer drawing with smooth strokes
  - Color picker (`flex_color_picker`) and adjustable stroke widths
  - Undo/redo and clear actions
  - Optimized repaint via `RepaintBoundary`
- Markdown editor with custom `RenderObject`:
  - Live preview with markdown parsing and syntax highlighting
  - Formatting toolbar (headers, bold, italic, code)
  - Split view with editor + preview
- Rendering guidance: `docs/custom_painter_and_render_object.md`

## Deep Links & Navigation

- Universal links (`https://links.flutterbloc.app/...`)
- Custom schemes (`flutter-bloc-app://`)
- Declarative navigation via GoRouter

## Developer Experience

- Built-in performance profiling tools
- Custom linting (file length, responsive spacing)
- Automated validation scripts via `./bin/checklist`
- Bug-prevention tests (`test/shared/common_bugs_prevention_test.dart`)
- CI/CD hooks via Fastlane and environment configs

## Access

- Whiteboard and Markdown Editor are accessible from the Home overflow menu.
