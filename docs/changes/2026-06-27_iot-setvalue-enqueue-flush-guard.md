# IoT demo: setValue enqueue flush guard

`OfflineFirstIotDemoRepository` keeps debounced `setValue` entries in the
pending-set-value guard until the sync enqueue finishes. This closes the
post-debounce window where `pullRemote` could apply stale remote devices before
the pending sync operation was visible.

Regression coverage:

```sh
flutter test test/features/iot_demo/data/offline_first_iot_demo_repository_test.dart --name "pullRemote does not overwrite local setValue while enqueue is flushing"
```
