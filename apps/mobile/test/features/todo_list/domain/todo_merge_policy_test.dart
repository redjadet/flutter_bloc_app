import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_merge_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const TodoMergePolicy policy = TodoMergePolicy();

  TodoItem item({
    required final String id,
    required final DateTime updatedAt,
    final bool synchronized = true,
  }) {
    final DateTime createdAt = updatedAt.subtract(const Duration(hours: 1));
    return TodoItem(
      id: id,
      title: 'title',
      createdAt: createdAt,
      updatedAt: updatedAt,
      synchronized: synchronized,
    );
  }

  test('accepts remote when local is missing', () {
    final TodoItem remote = item(id: 'a', updatedAt: DateTime.utc(2026, 1, 1));

    expect(policy.shouldApplyRemote(null, remote), isTrue);
  });

  test('rejects older remote when local is newer', () {
    final DateTime newer = DateTime.utc(2026, 1, 2);
    final DateTime older = DateTime.utc(2026, 1, 1);
    final TodoItem local = item(id: 'a', updatedAt: newer);
    final TodoItem remote = item(id: 'a', updatedAt: older);

    expect(policy.shouldApplyRemote(local, remote), isFalse);
  });

  test('accepts equal-or-newer remote when local is synchronized', () {
    final DateTime base = DateTime.utc(2026, 1, 1);
    final TodoItem local = item(id: 'a', updatedAt: base, synchronized: true);
    final TodoItem sameTime = item(
      id: 'a',
      updatedAt: base,
      synchronized: true,
    );
    final TodoItem newer = item(
      id: 'a',
      updatedAt: base.add(const Duration(seconds: 1)),
      synchronized: true,
    );

    expect(policy.shouldApplyRemote(local, sameTime), isTrue);
    expect(policy.shouldApplyRemote(local, newer), isTrue);
  });

  test('requires strictly newer remote when local has unsynced changes', () {
    final DateTime base = DateTime.utc(2026, 1, 1);
    final TodoItem local = item(id: 'a', updatedAt: base, synchronized: false);
    final TodoItem sameTime = item(
      id: 'a',
      updatedAt: base,
      synchronized: true,
    );
    final TodoItem newer = item(
      id: 'a',
      updatedAt: base.add(const Duration(seconds: 1)),
      synchronized: true,
    );

    expect(policy.shouldApplyRemote(local, sameTime), isFalse);
    expect(policy.shouldApplyRemote(local, newer), isTrue);
  });
}
