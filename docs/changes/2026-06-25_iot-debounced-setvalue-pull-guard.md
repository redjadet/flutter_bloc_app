# IoT demo: debounced setValue pull guard

`OfflineFirstIotDemoRepository.pullRemote` treats in-memory debounced
`setValue` commands and pending sync ops as pending local state for the active
Supabase user. Guards run both before `fetchDevices()` and immediately before
`replaceDevices()` so a mutation that starts during a slow remote fetch cannot
be overwritten by stale remote data.

Regression coverage:

```sh
flutter test test/features/iot_demo/data/offline_first_iot_demo_repository_test.dart --name "pullRemote does not overwrite local setValue"
```
