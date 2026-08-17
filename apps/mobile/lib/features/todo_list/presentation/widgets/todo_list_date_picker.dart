import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_ui/material_ui.dart';

part 'todo_list_date_picker.freezed.dart';
part 'todo_list_date_picker_dialog.part.dart';

@freezed
abstract class _DatePickerResult with _$DatePickerResult {
  const _DatePickerResult._();

  const factory _DatePickerResult.confirmed(DateTime date) =
      _DatePickerResultConfirmed;

  const factory _DatePickerResult.cleared() = _DatePickerResultCleared;

  DateTime? get date => when(
    confirmed: (date) => date,
    cleared: () => null,
  );

  bool get didConfirm => true;
}

String formatTodoDate(DateTime date) {
  final DateTime localDate = date.toLocal();
  return '${localDate.year}-'
      '${localDate.month.toString().padLeft(2, '0')}-'
      '${localDate.day.toString().padLeft(2, '0')}';
}
