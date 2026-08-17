import 'package:design_system/responsive.dart';
import 'package:material_ui/material_ui.dart';

enum TodoItemDensity {
  regular,
  compact,
  phoneLandscape;

  bool get isCompact => this != TodoItemDensity.regular;
  bool get showsDescription => this != TodoItemDensity.phoneLandscape;

  T resolve<T>({
    required T regular,
    required T compact,
    required T phoneLandscape,
  }) => switch (this) {
    TodoItemDensity.regular => regular,
    TodoItemDensity.compact => compact,
    TodoItemDensity.phoneLandscape => phoneLandscape,
  };
}

TodoItemDensity resolveTodoItemDensity(BuildContext context) {
  final Size screenSize = MediaQuery.sizeOf(context);
  final bool isPhoneLandscape =
      screenSize.width > screenSize.height && screenSize.shortestSide < 600;
  if (isPhoneLandscape) {
    return TodoItemDensity.phoneLandscape;
  }
  if (context.isCompactHeight) {
    return TodoItemDensity.compact;
  }
  return TodoItemDensity.regular;
}
