import 'package:flutter/material.dart';

class FixtureObjectKeyList extends StatelessWidget {
  const FixtureObjectKeyList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <String>['alpha', 'beta'];
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Text(
          items[index],
          key: ObjectKey(items[index]),
        );
      },
    );
  }
}
