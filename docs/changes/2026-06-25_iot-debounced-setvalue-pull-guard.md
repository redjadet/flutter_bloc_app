# IoT demo: debounced setValue pull guard

`OfflineFirstIotDemoRepository.pullRemote` now treats an in-memory debounced
`setValue` command as pending local state for the active Supabase user. This
closes the gap where a remote pull could land before the debounce timer enqueued
the sync operation and replace the local slider value with stale remote data.

Regression coverage:

```sh
flutter test test/features/iot_demo/data/offline_first_iot_demo_repository_test.dart --name "pullRemote does not overwrite local setValue while debounce is pending"
```
