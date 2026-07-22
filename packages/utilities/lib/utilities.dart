/// Pure Dart utilities (errors, retry, lifecycle helpers).
///
/// Public single-flight and request-staleness guards live in
/// `package:ilkersevim_async_utils` and are not re-exported here.
/// Completer + stream-controller lifecycle helpers live in
/// `package:ilkersevim_async_lifecycle` and are not re-exported here.
/// Safe dynamic/JSON parse helpers live in
/// `package:ilkersevim_safe_parse` and are not re-exported here.
/// Short relative-time labels live in
/// `package:ilkersevim_relative_time` and are not re-exported here.
/// DisposableBag / SubscriptionManager / TimerHandleManager /
/// TimerDisposable live in `package:ilkersevim_disposables` and are not
/// re-exported here (`TimerDisposable` is also re-exported from
/// `package:core` for existing timer imports).
library;

export 'src/diagnostics/diagnostics_sync_timestamp.dart';
export 'src/diagnostics/graphql_cache_clear_port.dart';
export 'src/diagnostics/profile_cache_controls_port.dart';
export 'src/errors/app_error.dart';
export 'src/errors/error_codes.dart';
export 'src/errors/failure_to_app_error.dart';
export 'src/errors/http_request_failure.dart';
export 'src/memory/app_memory_trim_level.dart';
export 'src/offline_change_id.dart';
export 'src/repositories/repository_initial_load_helper.dart';
export 'src/repositories/repository_watch_helper.dart';
export 'src/retry/retry_policy.dart';
export 'src/state/sealed_state_helpers.dart';
