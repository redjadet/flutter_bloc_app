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
    @Default('') final String searchQuery,
    final String? errorMessage,
  }) = _TodoListState;

  const TodoListState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasItems => items.isNotEmpty;

  List<TodoItem> get filteredItems {
    List<TodoItem> result = switch (filter) {
      TodoFilter.all => items,
      TodoFilter.active =>
        items.where((final item) => !item.isCompleted).toList(growable: false),
      TodoFilter.completed =>
        items.where((final item) => item.isCompleted).toList(growable: false),
    };

    if (searchQuery.isNotEmpty) {
      final String query = searchQuery.toLowerCase();
      result = result
          .where(
            (final item) =>
                item.title.toLowerCase().contains(query) ||
                (item.description?.toLowerCase().contains(query) ?? false),
          )
          .toList(growable: false);
    }

    return result;
  }

  bool get hasCompleted => items.any((final item) => item.isCompleted);
}
