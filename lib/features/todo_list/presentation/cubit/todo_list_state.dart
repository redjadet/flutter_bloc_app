import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_list_state.freezed.dart';

enum TodoFilter { all, active, completed }

@freezed
abstract class TodoListState with _$TodoListState {
  const factory TodoListState({
    @Default(ViewStatus.initial) final ViewStatus status,
    @Default(<TodoItem>[]) final List<TodoItem> items,
    @Default(TodoFilter.all) final TodoFilter filter,
    final String? errorMessage,
  }) = _TodoListState;

  const TodoListState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasItems => items.isNotEmpty;

  List<TodoItem> get filteredItems => switch (filter) {
    TodoFilter.all => items,
    TodoFilter.active =>
      items.where((final item) => !item.isCompleted).toList(growable: false),
    TodoFilter.completed =>
      items.where((final item) => item.isCompleted).toList(growable: false),
  };

  bool get hasCompleted => items.any((final item) => item.isCompleted);
}
