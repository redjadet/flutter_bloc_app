import 'package:flutter/material.dart';

class FixtureSearchRow extends StatefulWidget {
  const FixtureSearchRow({super.key});

  @override
  State<FixtureSearchRow> createState() => _FixtureSearchRowState();
}

class _FixtureSearchRowState extends State<FixtureSearchRow> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return TextField(focusNode: _focusNode);
  }
}

class FixturePanel extends StatelessWidget {
  const FixturePanel({required this.trailing, super.key});

  final List<Widget> trailing;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        FixtureSearchRow(key: ValueKey('fixture-search-row')),
        ...trailing,
      ],
    );
  }
}
