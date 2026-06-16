import 'package:flutter/material.dart';

class FixtureObjectKeyList extends StatelessWidget {
  const FixtureObjectKeyList({super.key});

  @override
  Widget build(final BuildContext context) {
    final items = <String>['alpha', 'beta'];
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (final context, final index) {
        return Text(
          items[index],
          key: ObjectKey(items[index]),
        );
      },
    );
  }
}
