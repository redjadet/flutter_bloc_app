fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android play_preflight

```sh
[bundle exec] fastlane android play_preflight
```

Run preflight checks for Android Play deploy lanes

### android preflight

```sh
[bundle exec] fastlane android preflight
```

Alias for play_preflight (backward compatibility)

### android play_build_release

```sh
[bundle exec] fastlane android play_build_release
```

Build a release appbundle via Flutter

### android build_release

```sh
[bundle exec] fastlane android build_release
```

Alias for play_build_release (backward compatibility)

### android play_metadata_sync

```sh
[bundle exec] fastlane android play_metadata_sync
```

Sync listing metadata/screenshots from fastlane/metadata/android to Play

### android metadata_sync

```sh
[bundle exec] fastlane android metadata_sync
```

Alias for play_metadata_sync (backward compatibility)

### android play_upload_internal

```sh
[bundle exec] fastlane android play_upload_internal
```

Build + upload AAB to Internal testing

### android upload_internal

```sh
[bundle exec] fastlane android upload_internal
```

Alias for play_upload_internal (backward compatibility)

### android play_upload_track

```sh
[bundle exec] fastlane android play_upload_track
```

Build + upload AAB to requested Play track

### android upload_track

```sh
[bundle exec] fastlane android upload_track
```

Alias for play_upload_track (backward compatibility)

### android play_promote_track

```sh
[bundle exec] fastlane android play_promote_track
```

Promote release from one Play track to another

### android promote_track

```sh
[bundle exec] fastlane android promote_track
```

Alias for play_promote_track (backward compatibility)

----


## iOS

### ios preflight

```sh
[bundle exec] fastlane ios preflight
```

Run preflight checks for iOS distribution lanes

### ios adhoc

```sh
[bundle exec] fastlane ios adhoc
```

Build and export an Ad Hoc IPA (no upload)

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Build + upload to TestFlight (App Store Connect)

### ios upload_appstore

```sh
[bundle exec] fastlane ios upload_appstore
```

Build + upload to App Store Connect (same binary as TestFlight)

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Alias for upload_testflight (backward compatibility)

### ios firebase_distribute

```sh
[bundle exec] fastlane ios firebase_distribute
```

Upload an iOS IPA to Firebase App Distribution

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
