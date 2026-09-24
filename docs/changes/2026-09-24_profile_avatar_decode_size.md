# Profile avatar decode size (2026-09-24)

## Why

The profile avatar source is 800×533 pixels, while its circular display is
128–160 logical pixels tall. Decoding the full source wastes image-cache
pixels on common device densities.

## Decision

- Set `cacheHeight` to rendered avatar height × device pixel ratio, rounded up
  and capped at the source height.
- Keep `BoxFit.cover`, source asset, and layout unchanged. Height drives the
  circular crop; a width-only hint could undersample it.
- Do not claim frame-time improvement without profile-mode UI/Raster traces.

## Must remain true

The decode hint must cover the rendered physical height and never exceed the
source height. The image stays sharp at supported display sizes and keeps its
existing crop.

## Failure and recovery

If the image appears soft or its crop changes at a device density, inspect the
device-pixel-ratio calculation and source dimensions, then adjust or remove the
hint. The source asset remains available as fallback.

## Rejected alternative

Leaving the full-size decode preserves sharpness but needlessly retains more
decoded pixels; sizing from width alone risks undersampling the height-driven
cover crop.

## Proof

- `flutter test --no-pub test/features/profile/presentation/profile_page_test.dart` — 3 passed.
- `./tool/analyze.sh --no-pub` — Flutter analyze, `mix_lint`, and `file_length_lint` passed.
- `./bin/checklist` on the PR head passed all tests and analysis but failed the
  required linked-change-note gate before this note was added; CI will rerun.
