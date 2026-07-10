import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/composition/features/register_todo_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/todo_list/data/offline_first_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storage/storage.dart';

class _MockHiveService extends Mock implements HiveService {}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _MockSyncableRepositoryRegistry extends Mock
    implements SyncableRepositoryRegistry {}

class _MockTimerService extends Mock implements TimerService {}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test('registerTodoServices registers offline-first TodoRepository', () {
    getIt.registerSingleton<HiveService>(_MockHiveService());
    getIt.registerSingleton<PendingSyncRepository>(
      _MockPendingSyncRepository(),
    );
    getIt.registerSingleton<SyncableRepositoryRegistry>(
      _MockSyncableRepositoryRegistry(),
    );
    getIt.registerSingleton<TimerService>(_MockTimerService());

    registerTodoServices();

    final repo = getIt<TodoRepository>();
    expect(repo, isA<OfflineFirstTodoRepository>());
  });
}
