import 'dart:async';

import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';

Future<void> overrideChartRepositoryForPerf({
  required final int pointCount,
}) async {
  if (getIt.isRegistered<ChartRepository>()) {
    await getIt.unregister<ChartRepository>();
  }
  getIt.registerSingleton<ChartRepository>(
    _PerfChartRepository(pointCount: pointCount),
  );
}

Future<void> overrideTodoRepositoryForPerf({
  required final int itemCount,
}) async {
  if (getIt.isRegistered<TodoRepository>()) {
    await getIt.unregister<TodoRepository>();
  }
  getIt.registerSingleton<TodoRepository>(
    _PerfTodoRepository(itemCount: itemCount),
  );
}

class _PerfChartRepository extends ChartRepository {
  _PerfChartRepository({required final int pointCount})
    : _points = List<ChartPoint>.generate(
        pointCount,
        (final i) => ChartPoint(
          date: DateTime.utc(2026).add(Duration(days: i)),
          value: 42000 + (i % 50) * 17.0,
        ),
        growable: false,
      );

  final List<ChartPoint> _points;

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async => _points;

  @override
  List<ChartPoint>? getCachedTrendingCounts() => _points;

  @override
  ChartDataSource get lastSource => ChartDataSource.cache;
}

class _PerfTodoRepository implements TodoRepository {
  _PerfTodoRepository({required final int itemCount})
    : _items = List<TodoItem>.generate(
        itemCount,
        (final i) => TodoItem.create(title: 'Perf seed todo $i'),
        growable: false,
      ) {
    _controller.add(_items);
  }

  final StreamController<List<TodoItem>> _controller =
      StreamController<List<TodoItem>>.broadcast();

  List<TodoItem> _items;

  @override
  Stream<List<TodoItem>> watchAll() => _controller.stream;

  @override
  Future<List<TodoItem>> fetchAll() async => _items;

  @override
  Future<void> save(final TodoItem item) async {
    final int existingIndex = _items.indexWhere((final e) => e.id == item.id);
    if (existingIndex == -1) {
      _items = <TodoItem>[item, ..._items];
    } else {
      final List<TodoItem> copy = List<TodoItem>.from(_items);
      copy[existingIndex] = item;
      _items = copy;
    }
    _controller.add(_items);
  }

  @override
  Future<void> delete(final String id) async {
    _items = _items.where((final e) => e.id != id).toList(growable: false);
    _controller.add(_items);
  }

  @override
  Future<void> clearCompleted() async {
    _items = _items.where((final e) => !e.isCompleted).toList(growable: false);
    _controller.add(_items);
  }
}
