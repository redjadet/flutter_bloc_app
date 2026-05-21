// Fixture: Row + two Material buttons without OverflowBar/Wrap/Expanded (must fail check).
import 'package:flutter/material.dart';

class BadRowTwoButtonsFixture {
  Widget build() => Row(
    children: <Widget>[
      OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
      FilledButton(onPressed: () {}, child: const Text('Save')),
    ],
  );
}
