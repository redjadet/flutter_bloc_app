/// Counter feature barrel file
library;

// Data exports
export 'data/counter_data.dart';
export 'data/realtime_database_counter_repository.dart';
export 'data/rest_counter_repository.dart';
export 'data/shared_preferences_counter_repository.dart';
// Domain exports
export 'domain/counter_domain.dart';
export 'domain/counter_error.dart';
export 'domain/counter_repository.dart';
export 'domain/counter_snapshot.dart';
// Presentation exports
export 'presentation/counter_cubit.dart';
export 'presentation/counter_state.dart';
export 'presentation/helpers/counter_error_localizer.dart';
export 'presentation/helpers/counter_snapshot_utils.dart';
export 'presentation/pages/counter_page.dart';
export 'presentation/widgets/widgets.dart';
