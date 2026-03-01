import 'package:flutter_bloc_app/features/todo_list/data/todo_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodoItemDto.fromMap', () {
    test('throws FormatException when id/title are not valid strings', () {
      expect(
        () => TodoItemDto.fromMap(<String, dynamic>{
          'id': 1,
          'title': true,
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
        }),
        throwsFormatException,
      );
    });

    test('parses valid map payload', () {
      final TodoItemDto dto = TodoItemDto.fromMap(<String, dynamic>{
        'id': 't1',
        'title': 'Title',
        'description': 'Desc',
        'isCompleted': 'true',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-01T01:00:00.000Z',
      });

      expect(dto.id, 't1');
      expect(dto.title, 'Title');
      expect(dto.description, 'Desc');
      expect(dto.isCompleted, isTrue);
    });
  });
}
