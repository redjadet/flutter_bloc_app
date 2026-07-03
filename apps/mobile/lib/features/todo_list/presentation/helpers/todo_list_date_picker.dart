import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_list_date_picker.freezed.dart';
part 'todo_list_date_picker_dialog.part.dart';

@freezed
abstract class _DatePickerResult with _$DatePickerResult {
  const _DatePickerResult._();

  const factory _DatePickerResult.confirmed(final DateTime date) =
      _DatePickerResultConfirmed;

  const factory _DatePickerResult.cleared() = _DatePickerResultCleared;

  DateTime? get date => when(
    confirmed: (final date) => date,
    cleared: () => null,
  );

  bool get didConfirm => true;
}

String formatTodoDate(final DateTime date) {
  final DateTime localDate = date.toLocal();
  return '${localDate.year}-'
      '${localDate.month.toString().padLeft(2, '0')}-'
      '${localDate.day.toString().padLeft(2, '0')}';
}
