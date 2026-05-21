// Fixture: dual CTAs via ResponsiveDualCtaRow (no standalone Row( — must pass check).
import 'package:flutter/material.dart';

class GoodDualCtaResponsiveFixture {
  Widget build() => ResponsiveDualCtaRow(
    start: OutlinedButton(onPressed: () {}, child: const Text('A')),
    end: FilledButton(onPressed: () {}, child: const Text('B')),
  );
}

// Stub so awk-only fixture scan does not require package import resolution.
class ResponsiveDualCtaRow extends StatelessWidget {
  const ResponsiveDualCtaRow({
    required this.start,
    required this.end,
    super.key,
  });
  final Widget start;
  final Widget end;
  @override
  Widget build(BuildContext context) => start;
}
