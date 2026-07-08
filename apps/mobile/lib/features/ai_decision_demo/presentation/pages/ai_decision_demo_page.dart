// check-ignore: nonbuilder_lists - small, fixed-size page content

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_cubit.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_state.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/pages/ai_decision_demo_proof_widgets.dart';

part 'ai_decision_demo_page.part.dart';

class AiDecisionDemoPage extends StatefulWidget {
  const AiDecisionDemoPage({super.key});

  @override
  State<AiDecisionDemoPage> createState() => _AiDecisionDemoPageState();
}

class _AiDecisionDemoPageState extends State<AiDecisionDemoPage> {
  final TextEditingController _operatorNote = TextEditingController();
  final TextEditingController _actionNote = TextEditingController();

  Color _bandColor(final ColorScheme colors, final String band) =>
      switch (band) {
        'low' => colors.tertiary,
        'medium' => colors.secondary,
        'high' => colors.error,
        _ => colors.primary,
      };

  Widget _pill({
    required final BuildContext context,
    required final String label,
    required final Color color,
  }) => buildAiDecisionPill(context: context, label: label, color: color);

  @override
  void dispose() {
    _operatorNote.dispose();
    _actionNote.dispose();
    super.dispose();
  }

  void _onCaseChanged(final BuildContext blocContext, final String? value) {
    if (value == null) {
      return;
    }
    unawaited(blocContext.cubit<AiDecisionCubit>().loadCase(value));
  }

  void _onRunDecisionSupport(final BuildContext blocContext) {
    unawaited(
      blocContext.cubit<AiDecisionCubit>().runDecisionSupport(
        operatorNote: _operatorNote.text,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    const title = 'AI Decision Workbench';
    return CommonPageLayout(
      title: title,
      body: Builder(
        builder: (final context) {
          return _buildBody(
            context: context,
            operatorNote: _operatorNote,
            actionNote: _actionNote,
            onCaseChanged: _onCaseChanged,
            onRunDecisionSupport: _onRunDecisionSupport,
            bandColor: _bandColor,
            pillBuilder: _pill,
          );
        },
      ),
    );
  }
}
