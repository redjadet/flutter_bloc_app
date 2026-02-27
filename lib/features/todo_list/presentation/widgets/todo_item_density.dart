import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

enum TodoItemDensity {
  regular,
  compact,
  phoneLandscape;

  bool get isCompact => this != TodoItemDensity.regular;
  bool get showsDescription => this != TodoItemDensity.phoneLandscape;

  T resolve<T>({
    required final T regular,
    required final T compact,
    required final T phoneLandscape,
  }) => switch (this) {
    TodoItemDensity.regular => regular,
    TodoItemDensity.compact => compact,
    TodoItemDensity.phoneLandscape => phoneLandscape,
  };
}

TodoItemDensity resolveTodoItemDensity(final BuildContext context) {
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
