import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l10n.calculatorTitle),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final bool isCompact = constraints.maxHeight < 640;
            final EdgeInsets padding = EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isCompact ? 12 : 8,
            );

            Widget content;
            if (isCompact) {
              content = SingleChildScrollView(
                padding: padding,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24),
                    _CalculatorDisplay(),
                    SizedBox(height: 24),
                    CalculatorKeypad(shrinkWrap: true),
                    SizedBox(height: 24),
                  ],
                ),
              );
            } else {
              content = SizedBox(
                height: constraints.maxHeight,
                child: Padding(
                  padding: padding,
                  child: const _CalculatorBody(),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CalculatorBody extends StatelessWidget {
  const _CalculatorBody();

  @override
  Widget build(final BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: 32),
      _CalculatorDisplay(),
      SizedBox(height: 32),
      Expanded(child: CalculatorKeypad()),
    ],
  );
}

class _CalculatorDisplay extends StatelessWidget {
  const _CalculatorDisplay();

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<CalculatorCubit, CalculatorState>(
        buildWhen: (final previous, final current) =>
            previous.display != current.display ||
            previous.history != current.history,
        builder: (final context, final state) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.history.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    state.history,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    state.display,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
