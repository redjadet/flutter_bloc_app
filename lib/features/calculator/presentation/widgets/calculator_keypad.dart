import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:go_router/go_router.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({super.key, this.shrinkWrap = false});

  final bool shrinkWrap;

  @override
  Widget build(final BuildContext context) {
    final CalculatorCubit cubit = context.read<CalculatorCubit>();
    final double spacing = context.responsiveGapL;
    final List<_ButtonConfig> buttons = <_ButtonConfig>[
      _ButtonConfig(
        label: '⌫',
        type: _ButtonType.function,
        onPressed: cubit.backspace,
      ),
      _ButtonConfig(
        label: 'AC',
        type: _ButtonType.function,
        onPressed: cubit.clearAll,
      ),
      _ButtonConfig(
        label: '%',
        type: _ButtonType.function,
        onPressed: cubit.applyPercentage,
      ),
      _ButtonConfig(
        label: '÷',
        type: _ButtonType.operation,
        onPressed: () => cubit.selectOperation(CalculatorOperation.divide),
      ),
      _digit('7', cubit),
      _digit('8', cubit),
      _digit('9', cubit),
      _operation(
        '×',
        () => cubit.selectOperation(CalculatorOperation.multiply),
      ),
      _digit('4', cubit),
      _digit('5', cubit),
      _digit('6', cubit),
      _operation(
        '−',
        () => cubit.selectOperation(CalculatorOperation.subtract),
      ),
      _digit('1', cubit),
      _digit('2', cubit),
      _digit('3', cubit),
      _operation('+', () => cubit.selectOperation(CalculatorOperation.add)),
      _ButtonConfig(
        label: '+/−',
        type: _ButtonType.function,
        onPressed: cubit.toggleSign,
      ),
      _digit('0', cubit),
      _ButtonConfig(
        label: '.',
        type: _ButtonType.number,
        onPressed: cubit.inputDecimalPoint,
      ),
      _ButtonConfig(
        label: '=',
        type: _ButtonType.operation,
        onPressed: () {
          cubit.evaluate();
          unawaited(
            context.pushNamed(
              AppRoutes.calculatorPayment,
              extra: cubit,
            ),
          );
        },
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
      itemBuilder: (final context, final index) =>
          _CalculatorButton(config: buttons[index]),
    );
  }
}

_ButtonConfig _digit(final String label, final CalculatorCubit cubit) =>
    _ButtonConfig(
      label: label,
      type: _ButtonType.number,
      onPressed: () => cubit.inputDigit(label),
    );

_ButtonConfig _operation(final String label, final VoidCallback onPressed) =>
    _ButtonConfig(
      label: label,
      type: _ButtonType.operation,
      onPressed: onPressed,
    );

enum _ButtonType { number, operation, function }

class _ButtonConfig {
  const _ButtonConfig({
    required this.label,
    required this.onPressed,
    required this.type,
  });

  final String label;
  final VoidCallback onPressed;
  final _ButtonType type;
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({required this.config});

  final _ButtonConfig config;

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

    return Material(
      color: background,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white24),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: config.onPressed,
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
