// Fixture: OverflowBar mitigation (must pass check).
import 'package:flutter/material.dart';

class GoodOverflowBarFixture {
  Widget build() => OverflowBar(
    alignment: MainAxisAlignment.end,
    spacing: 12,
    overflowSpacing: 12,
    children: <Widget>[
      TextButton(onPressed: () {}, child: const Text('Cancel')),
      FilledButton(onPressed: () {}, child: const Text('Save')),
    ],
  );
}
