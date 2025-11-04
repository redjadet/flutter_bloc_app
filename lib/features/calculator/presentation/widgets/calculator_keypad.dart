import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_actions.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:go_router/go_router.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({super.key, this.shrinkWrap = false});

  final bool shrinkWrap;

  @override
  Widget build(final BuildContext context) {
    final CalculatorCubit cubit = context.read<CalculatorCubit>();
    final double spacing = context.responsiveGapL;
    final CalculatorActions actions = CalculatorCubitActions(cubit);
    final List<_ButtonConfig> buttons = <_ButtonConfig>[
      const _ButtonConfig.function(
        label: '⌫',
        command: BackspaceCommand(),
      ),
      const _ButtonConfig.function(
        label: 'AC',
        command: ClearAllCommand(),
      ),
      const _ButtonConfig.function(
        label: '%',
        command: ApplyPercentageCommand(),
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
      const _ButtonConfig.function(
        label: '+/−',
        command: ToggleSignCommand(),
      ),
      _digit('0'),
      const _ButtonConfig.number(
        label: '.',
        command: DecimalCommand(),
      ),
      const _ButtonConfig.operation(
        label: '=',
        command: EvaluateCommand(),
      ),
    ];

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
        onEvaluate: () => unawaited(
          context.pushNamed(
            AppRoutes.calculatorPayment,
            extra: cubit,
          ),
        ),
      ),
    );
  }
}

_ButtonConfig _digit(final String label) => _ButtonConfig.number(
  label: label,
  command: DigitCommand(label),
);

enum _ButtonType { number, operation, function }

class _ButtonConfig {
  const _ButtonConfig._({
    required this.label,
    required this.type,
    required this.command,
  });

  const _ButtonConfig.number({
    required String label,
    required CalculatorCommand command,
  }) : this._(
         label: label,
         type: _ButtonType.number,
         command: command,
       );

  const _ButtonConfig.operation({
    required String label,
    required CalculatorCommand command,
  }) : this._(
         label: label,
         type: _ButtonType.operation,
         command: command,
       );

  const _ButtonConfig.function({
    required String label,
    required CalculatorCommand command,
  }) : this._(
         label: label,
         type: _ButtonType.function,
         command: command,
       );

  final String label;
  final _ButtonType type;
  final CalculatorCommand command;
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.config,
    required this.actions,
    required this.onEvaluate,
  });

  final _ButtonConfig config;
  final CalculatorActions actions;
  final VoidCallback onEvaluate;

  @override
  Widget build(final BuildContext context) {
    final Color background = switch (config.type) {
      _ButtonType.number => const Color(0xFF333333),
      _ButtonType.function => const Color(0xFFA5A5A5),
      _ButtonType.operation => const Color(0xFFFF9500),
    };
    final Color foreground = switch (config.type) {
      _ButtonType.function => Colors.black,
      _ButtonType.number => Colors.white,
      _ButtonType.operation => Colors.white,
    };
    final bool triggersEvaluation = config.command is EvaluateCommand;

    return Material(
      color: background,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white24),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          config.command.execute(actions);
          if (triggersEvaluation) {
            onEvaluate();
          }
        },
        child: Center(
          child: Text(
            config.label,
            style: TextStyle(
              color: foreground,
              fontSize: 26,
              fontWeight: config.type == _ButtonType.operation
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
