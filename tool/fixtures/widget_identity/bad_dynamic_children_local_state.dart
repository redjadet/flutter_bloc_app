import 'package:flutter/material.dart';

class FixtureSearchRow extends StatefulWidget {
  const FixtureSearchRow({super.key});

  @override
  State<FixtureSearchRow> createState() => _FixtureSearchRowState();
}

class _FixtureSearchRowState extends State<FixtureSearchRow> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}

class FixturePanel extends StatelessWidget {
  const FixturePanel({required this.trailing, super.key});

  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FixtureSearchRow(),
        ...trailing,
      ],
    );
  }
}
