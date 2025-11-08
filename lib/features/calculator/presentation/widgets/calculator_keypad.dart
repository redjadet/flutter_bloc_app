import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_actions.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:go_router/go_router.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({super.key, this.shrinkWrap = false});

  final bool shrinkWrap;

  @override
  Widget build(final BuildContext context) {
    final CalculatorCubit cubit = context.read<CalculatorCubit>();
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
        onEvaluate: () => unawaited(
          context.pushNamed(
            AppRoutes.calculatorPayment,
            extra: cubit,
          ),
        ),
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
    this.semanticsLabel,
    this.tooltip,
  });

  const _ButtonConfig.number({
    required String label,
    required CalculatorCommand command,
    String? semanticsLabel,
    String? tooltip,
  }) : this._(
         label: label,
         type: _ButtonType.number,
         command: command,
         semanticsLabel: semanticsLabel,
         tooltip: tooltip,
       );

  const _ButtonConfig.operation({
    required String label,
    required CalculatorCommand command,
    String? semanticsLabel,
    String? tooltip,
  }) : this._(
         label: label,
         type: _ButtonType.operation,
         command: command,
         semanticsLabel: semanticsLabel,
         tooltip: tooltip,
       );

  const _ButtonConfig.function({
    required String label,
    required CalculatorCommand command,
    String? semanticsLabel,
    String? tooltip,
  }) : this._(
         label: label,
         type: _ButtonType.function,
         command: command,
         semanticsLabel: semanticsLabel,
         tooltip: tooltip,
       );

  final String label;
  final _ButtonType type;
  final CalculatorCommand command;
  final String? semanticsLabel;
  final String? tooltip;
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.config,
    required this.actions,
    required this.onEvaluate,
    required this.palette,
  });

  final _ButtonConfig config;
  final CalculatorActions actions;
  final VoidCallback onEvaluate;
  final _CalculatorPalette palette;

  @override
  Widget build(final BuildContext context) {
    final _CalculatorButtonStyle style = palette.styleFor(config.type);
    final bool triggersEvaluation = config.command is EvaluateCommand;
    final ThemeData theme = Theme.of(context);
    final bool useCupertino = PlatformAdaptive.isCupertinoFromTheme(theme);

    void handleTap() {
      config.command.execute(actions);
      if (triggersEvaluation) {
        onEvaluate();
      }
    }

    final Widget label = Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          config.label,
          style: TextStyle(
            color: style.foreground,
            fontSize: 26,
            fontWeight: config.type == _ButtonType.operation
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
    );

    Widget button;
    if (useCupertino) {
      button = ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.background,
            shape: BoxShape.circle,
            border: Border.all(color: palette.borderColor),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(999),
            onPressed: handleTap,
            child: label,
          ),
        ),
      );
    } else {
      button = Material(
        color: style.background,
        shape: CircleBorder(side: BorderSide(color: palette.borderColor)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: handleTap,
          child: label,
        ),
      );
    }

    final String? tooltip = config.tooltip;
    if (tooltip != null && tooltip.isNotEmpty) {
      button = Tooltip(message: tooltip, child: button);
    }

    final String semanticsLabel = config.semanticsLabel ?? config.label;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: button,
    );
  }
}

class _CalculatorPalette {
  const _CalculatorPalette({
    required this.number,
    required this.function,
    required this.operation,
    required this.borderColor,
  });

  factory _CalculatorPalette.fromTheme(final ThemeData theme) {
    final ColorScheme colors = theme.colorScheme;
    return _CalculatorPalette(
      number: _CalculatorButtonStyle(
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurface,
      ),
      function: _CalculatorButtonStyle(
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      ),
      operation: _CalculatorButtonStyle(
        background: colors.primary,
        foreground: colors.onPrimary,
      ),
      borderColor: colors.outlineVariant.withValues(alpha: 0.5),
    );
  }

  final _CalculatorButtonStyle number;
  final _CalculatorButtonStyle function;
  final _CalculatorButtonStyle operation;
  final Color borderColor;

  _CalculatorButtonStyle styleFor(final _ButtonType type) => switch (type) {
    _ButtonType.number => number,
    _ButtonType.function => function,
    _ButtonType.operation => operation,
  };
}

class _CalculatorButtonStyle {
  const _CalculatorButtonStyle({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
