import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/widgets/slot_machine_spinner.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/widgets/slot_symbol_text_style.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_with_mix_theme.dart';

void main() {
  testWidgets('SlotMachineSpinner renders gem as an Icon', (
    WidgetTester tester,
  ) async {
    await pumpWithMixTheme(
      tester,
      child: const Material(
        child: SlotMachineSpinner(
          duration: Duration(milliseconds: 1),
          staticProgress: 0,
        ),
      ),
    );

    // Unicode symbols are rendered as Icons for reliable display (e.g. on iOS).
    expect(find.byIcon(Icons.diamond), findsWidgets);
    expect(find.byIcon(Icons.star), findsWidgets);
    expect(find.byIcon(Icons.circle), findsWidgets);

    expect(kSlotReelSymbols.contains(kSlotGemSymbol), isTrue);
    for (final String symbol in kSlotSymbolToIcon.keys) {
      expect(kSlotReelSymbols.contains(symbol), isTrue);
    }
  });
}
