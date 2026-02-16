import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_actions.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:go_router/go_router.dart';

part 'calculator_keypad_button.dart';
part 'calculator_keypad_config.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({super.key, this.shrinkWrap = false});

  final bool shrinkWrap;

  @override
  Widget build(final BuildContext context) {
    final CalculatorCubit cubit = context.cubit<CalculatorCubit>();
    final double spacing = context.responsiveGapL;
    final CalculatorActions actions = CalculatorCubitActions(cubit);
    final _CalculatorPalette palette = _CalculatorPalette.fromTheme(
      Theme.of(context),
    );
    final List<_ButtonConfig> buttons = _buildButtons(context);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: buttons.length,
      itemBuilder: (final context, final index) => _CalculatorButton(
        config: buttons[index],
        actions: actions,
        palette: palette,
        onEvaluate: () {
          if (cubit.state.error != null) {
            return;
          }
          // check-ignore: navigation is triggered by user action
          unawaited(
            context.pushNamed(
              AppRoutes.calculatorPayment,
              extra: cubit,
            ),
          );
        },
      ),
    );
  }

  List<_ButtonConfig> _buildButtons(final BuildContext context) {
    final l10n = context.l10n;
    return <_ButtonConfig>[
      _ButtonConfig.function(
        label: '⌫',
        semanticsLabel: l10n.calculatorBackspace,
        tooltip: l10n.calculatorBackspace,
        command: const BackspaceCommand(),
      ),
      _ButtonConfig.function(
        label: 'AC',
        semanticsLabel: l10n.calculatorClearLabel,
        tooltip: l10n.calculatorClearLabel,
        command: const ClearAllCommand(),
      ),
      _ButtonConfig.function(
        label: '%',
        semanticsLabel: l10n.calculatorPercentCommand,
        tooltip: l10n.calculatorPercentCommand,
        command: const ApplyPercentageCommand(),
      ),
      const _ButtonConfig.operation(
        label: '÷',
        command: OperationCommand(CalculatorOperation.divide),
      ),
      _digit('7'),
      _digit('8'),
      _digit('9'),
      const _ButtonConfig.operation(
        label: '×',
        command: OperationCommand(CalculatorOperation.multiply),
      ),
      _digit('4'),
      _digit('5'),
      _digit('6'),
      const _ButtonConfig.operation(
        label: '−',
        command: OperationCommand(CalculatorOperation.subtract),
      ),
      _digit('1'),
      _digit('2'),
      _digit('3'),
      const _ButtonConfig.operation(
        label: '+',
        command: OperationCommand(CalculatorOperation.add),
      ),
      _ButtonConfig.function(
        label: '+/−',
        semanticsLabel: l10n.calculatorToggleSign,
        tooltip: l10n.calculatorToggleSign,
        command: const ToggleSignCommand(),
      ),
      _digit('0'),
      _ButtonConfig.number(
        label: '.',
        semanticsLabel: l10n.calculatorDecimalPointLabel,
        tooltip: l10n.calculatorDecimalPointLabel,
        command: const DecimalCommand(),
      ),
      _ButtonConfig.operation(
        label: '=',
        semanticsLabel: l10n.calculatorEquals,
        tooltip: l10n.calculatorEquals,
        command: const EvaluateCommand(),
      ),
    ];
  }
}
