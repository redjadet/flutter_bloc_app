# EPOCH Library Demo

A Flutter implementation of the EPOCH Library interface based on the Figma design specifications.

## Overview

This feature demonstrates a library management interface with:

- Asset browsing (Objects, Images, Sound, Footage)
- Category navigation (Scapes, Packs)
- Search functionality
- Grid/List view toggles
- Audio waveform visualization

## Design System

### Colors

The EPOCH design system uses a custom color palette defined in `library_demo_theme.dart`:

| Color Name | Hex | Usage |
| ---------- | --- | ----- |
| Warm Grey Lightest | #E8E7DE | Primary text and icons on dark backgrounds |
| Warm Grey | #9D9C93 | Placeholder text |
| Ash | #877A7A | Secondary text and metadata |
| Ash Darker | #736868 | Waveform visualization |
| Dark Grey | #231F20 | Main panel background |
| Pink | #FFC9C1 | Audio asset background (alternative) |
| Purple | #C4BAFF | Audio asset background (primary) |

### Typography

The design uses two font families:

1. **Libre Caslon Text** (serif)
   - Wordmark: 60px, -1.8px letter spacing
   - Headings: 24px, -0.72px letter spacing
   - Asset Names: 18px, -0.36px letter spacing

2. **IBM Plex Mono** (monospace)
   - Labels: 18px, SemiBold, -0.9px letter spacing
   - Metadata: 14px, SemiBold, -0.28px letter spacing
   - Search Placeholder: 18px, Light, -0.9px letter spacing

### Spacing

Consistent spacing values from `EpochSpacing`:

- Top padding: 32px
- Panel padding: 16px horizontal, 20px top, 32px bottom
- Gap tight: 4px
- Gap medium: 16px
- Gap large: 20px
- Gap section: 24px
- Gap sections: 32px
- Button size: 48x48px
- Asset thumbnail: 56x56px
- Border radius large: 10px
- Border radius small: 4px

## File Structure

```text
lib/features/library_demo/
├── presentation/
│   ├── pages/
│   │   └── library_demo_page.dart          # Main page wrapper
│   └── widgets/
│       ├── library_demo_asset_tile.dart    # Individual asset row
│       ├── library_demo_assets_header.dart # "All Assets" header with view toggles
│       ├── library_demo_body.dart          # Main body content
│       ├── library_demo_category_list.dart # Scapes/Packs navigation
│       ├── library_demo_favorite_icon.dart # Custom star icon
│       ├── library_demo_filter_icon.dart   # Custom filter icon
│       ├── library_demo_menu_icon.dart     # Custom hamburger menu
│       ├── library_demo_models.dart        # Data models
│       ├── library_demo_search_row.dart    # Search bar with filter button
│       ├── library_demo_theme.dart         # Design system (colors, typography, spacing)
│       ├── library_demo_three_dot_icon.dart # Custom menu icon
│       ├── library_demo_top_nav.dart       # Top navigation bar
│       ├── library_demo_view_icons.dart    # Grid/List view icons
│       ├── library_demo_waveform.dart      # Audio waveform visualization
│       └── library_demo_wordmark.dart      # EPOCH wordmark/logo
└── README.md                               # This file
```

## Components

### LibraryDemoPage

Main page wrapper that provides the `CommonPageLayout` and localizations.

### LibraryDemoBody

The main content container that composes all the library interface elements:

- Top navigation with menu button
- EPOCH wordmark
- Dark panel containing:
  - Library heading
  - Search row
  - Category navigation
  - Assets list

### LibraryTopNav

Navigation bar with a hamburger menu button (custom hamburger icon).

### LibraryWordmark

Large "EPOCH" text using Libre Caslon Text font.

### LibrarySearchRow

Search input field with filter button, styled with EPOCH colors.

### LibraryCategoryList

Two navigation items: "SCAPES" and "PACKS" with custom chevron icons.

### LibraryAssetsHeader

Section header with "All Assets" title and grid/list view toggle icons.

### LibraryAssetTile

Individual asset row displaying:

- Thumbnail (image or waveform for audio)
- Asset name
- Asset type (OBJECT, IMAGE, SOUND, FOOTAGE)
- Duration (00:00)
- Format (OBJ, JPG, MP4, MP3)
- Favorite icon
- Three-dot menu

### Custom Icons

All icons are custom-drawn to match the Figma design:

- `LibraryMenuIcon` - Hamburger menu (3 horizontal lines)
- `LibraryFilterIcon` - Filter icon with adjustable sliders
- `LibraryFavoriteIcon` - Star/asterisk icon (3 intersecting lines)
- `LibraryThreeDotIcon` - Vertical three-dot menu
- `LibraryGridViewIcon` - 2x2 grid squares
- `LibraryListViewIcon` - List with bullets and lines

### LibraryWaveform

Audio visualization with vertical lines clipped to thumbnail size.

## Data Models

### LibraryAsset

```dart
class LibraryAsset {
  final String name;
  final String type;  // OBJECT, IMAGE, SOUND, FOOTAGE
  final String durationLabel;
  final String formatLabel;
  final String? thumbnailAssetPath;
  final Color? backgroundColor;  // For audio assets

  bool get isAudio;  // Helper to check if type is SOUND
}
```

### LibraryCategory

```dart
class LibraryCategory {
  final String label;  // SCAPES, PACKS
}
```

## Usage

The library demo is accessible from the main examples page:

```dart
import 'package:flutter_bloc_app/features/library_demo/presentation/pages/library_demo_page.dart';

// Navigate to library demo
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LibraryDemoPage(),
  ),
);
```

## Localization

All user-facing text is localized using the app's localization system. Keys are prefixed with `libraryDemo*`:

- `libraryDemoBrandName` - "Epoch"
- `libraryDemoPanelTitle` - "Library"
- `libraryDemoSearchHint` - "Search your library"
- `libraryDemoCategoryScapes` - "Scapes"
- `libraryDemoCategoryPacks` - "Packs"
- `libraryDemoAssetsTitle` - "All Assets"
- And more for asset types and formats

## Font Installation

To see the exact design, you need to install the custom fonts:

### 1. Download Fonts

Download these font files:

- [Libre Caslon Text](https://fonts.google.com/specimen/Libre+Caslon+Text) - Regular weight
- [IBM Plex Mono](https://fonts.google.com/specimen/IBM+Plex+Mono) - Light (300) and SemiBold (600) weights

### 2. Add to Project

Place font files in `assets/fonts/`:

```text
assets/fonts/
  LibreCaslonText-Regular.ttf
  IBMPlexMono-Light.ttf
  IBMPlexMono-SemiBold.ttf
```

### 3. Update pubspec.yaml

Add font definitions to `pubspec.yaml`:

```yaml
fonts:
  - family: LibreCaslonText
    fonts:
      - asset: assets/fonts/LibreCaslonText-Regular.ttf
  - family: IBMPlexMono
    fonts:
      - asset: assets/fonts/IBMPlexMono-Light.ttf
        weight: 300
      - asset: assets/fonts/IBMPlexMono-SemiBold.ttf
        weight: 600
```

### 4. Run pub get

```bash
flutter pub get
```

## Design Compliance

✅ **Colors** - All colors match Figma hex values exactly
✅ **Typography** - Font families, sizes, weights, and letter spacing match design
✅ **Spacing** - All padding, gaps, and sizing match specifications
✅ **Icons** - Custom-drawn icons match Figma design
✅ **Layout** - Structure and hierarchy match Figma design
✅ **Borders** - Border radius and opacity match design
✅ **Waveform** - Audio visualization matches design
✅ **Responsive** - Works on different screen sizes

## Notes

- The design uses a dark panel (#231F20) against a lighter background
- Audio assets display a waveform visualization instead of thumbnails
- Audio assets can have pink (#FFC9C1) or purple (#C4BAFF) backgrounds
- All text in labels and metadata is uppercase
- Border dividers use 35% opacity
- Search field and filter button use 50% opacity ash color
- The hamburger menu button has a warm grey lightest background (#E8E7DE)

## Future Enhancements

Potential improvements:

- Implement actual search functionality
- Add filter dialog/bottom sheet
- Implement grid view layout
- Add asset detail pages
- Implement favorite toggle functionality
- Add three-dot menu actions
- Connect to real data source/API
- Add animations and transitions
- Implement audio playback for sound assets
- Add image zoom for visual assets
