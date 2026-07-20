/// Pure Dart utilities (single-flight gates, request-id guards, time labels).
library;

export 'src/async/completer_helper.dart';
export 'src/diagnostics/diagnostics_sync_timestamp.dart';
export 'src/diagnostics/graphql_cache_clear_port.dart';
export 'src/diagnostics/profile_cache_controls_port.dart';
export 'src/disposable_bag.dart';
export 'src/errors/app_error.dart';
export 'src/errors/error_codes.dart';
export 'src/errors/failure_to_app_error.dart';
export 'src/errors/http_request_failure.dart';
export 'src/in_flight_coalescer.dart';
export 'src/memory/app_memory_trim_level.dart';
export 'src/offline_change_id.dart';
export 'src/relative_time_formatting.dart';
export 'src/repositories/repository_initial_load_helper.dart';
export 'src/repositories/repository_watch_helper.dart';
export 'src/request_id_guard.dart';
export 'src/retry/retry_policy.dart';
export 'src/safe_parse_utils.dart';
export 'src/state/sealed_state_helpers.dart';
export 'src/subscriptions/subscription_manager.dart';
export 'src/streams/stream_controller_lifecycle.dart';
export 'src/timers/timer_handle_manager.dart';
