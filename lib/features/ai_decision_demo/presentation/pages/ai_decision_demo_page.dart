// check-ignore: nonbuilder_lists - small, fixed-size page content

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_repository.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_cubit.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/cubit/ai_decision_state.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/presentation/pages/ai_decision_demo_proof_widgets.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

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
    return BlocProviderHelpers.withAsyncInit<AiDecisionCubit>(
      create: () => AiDecisionCubit(repository: getIt<AiDecisionRepository>()),
      init: (final cubit) => cubit.loadQueue(),
      child: CommonPageLayout(
        title: title,
        body: Builder(
          builder: (final context) {
            final shellState = context
                .selectState<
                  AiDecisionCubit,
                  AiDecisionState,
                  ({
                    bool isLoadingQueue,
                    List<AiDecisionCaseSummary> queue,
                    String? errorMessage,
                  })
                >(
                  selector: (final state) => (
                    isLoadingQueue: state.isLoadingQueue,
                    queue: state.queue,
                    errorMessage: state.errorMessage,
                  ),
                );

            if (shellState.isLoadingQueue) {
              return const Center(child: CircularProgressIndicator());
            }

            if (shellState.errorMessage case final String errorMessage?) {
              return CommonErrorView(
                message: errorMessage,
                onRetry: () => context.cubit<AiDecisionCubit>().loadQueue(),
              );
            }

            if (shellState.queue.isEmpty) {
              return const Center(
                // check-ignore: demo copy (not localized yet)
                child: Text('No cases (seed the backend DB).'),
              );
            }

            return _AiDecisionWorkbench(
              queue: shellState.queue,
              operatorNote: _operatorNote,
              actionNote: _actionNote,
              onCaseChanged: _onCaseChanged,
              onRunDecisionSupport: _onRunDecisionSupport,
              bandColor: _bandColor,
              pillBuilder: _pill,
            );
          },
        ),
      ),
    );
  }
}

class _AiDecisionWorkbench extends StatelessWidget {
  const _AiDecisionWorkbench({
    required this.queue,
    required this.operatorNote,
    required this.actionNote,
    required this.onCaseChanged,
    required this.onRunDecisionSupport,
    required this.bandColor,
    required this.pillBuilder,
  });

  final List<AiDecisionCaseSummary> queue;
  final TextEditingController operatorNote;
  final TextEditingController actionNote;
  final void Function(BuildContext context, String? value) onCaseChanged;
  final void Function(BuildContext context) onRunDecisionSupport;
  final Color Function(ColorScheme colors, String band) bandColor;
  final Widget Function({
    required BuildContext context,
    required String label,
    required Color color,
  })
  pillBuilder;

  @override
  Widget build(final BuildContext context) {
    final selectedId = context
        .selectState<AiDecisionCubit, AiDecisionState, String?>(
          selector: (final state) => state.selectedCaseId,
        );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: <Widget>[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: selectedId ?? queue.first.id,
            items: queue
                .map(
                  (final c) => DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(
                      '${c.id} • ${c.businessName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (final value) => onCaseChanged(context, value),
            decoration: const InputDecoration(
              labelText: 'Case',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const _AiDecisionCaseDetailSection(),
          TextField(
            controller: operatorNote,
            decoration: const InputDecoration(
              labelText: 'Operator note (optional)',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _AiDecisionRunButton(onRunDecisionSupport: onRunDecisionSupport),
          const SizedBox(height: 16),
          _AiDecisionDecisionSection(
            bandColor: bandColor,
            pillBuilder: pillBuilder,
          ),
          const Divider(),
          TextField(
            controller: actionNote,
            decoration: const InputDecoration(
              labelText: 'Action note',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          _AiDecisionActionButtons(actionNote: actionNote),
          const SizedBox(height: 16),
          const _AiDecisionActionHistorySection(),
        ],
      ),
    );
  }
}

class _AiDecisionCaseDetailSection extends StatelessWidget {
  const _AiDecisionCaseDetailSection();

  @override
  Widget build(final BuildContext context) {
    final detail = context
        .selectState<AiDecisionCubit, AiDecisionState, AiDecisionCaseDetail?>(
          selector: (final state) => state.caseDetail,
        );

    if (detail == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // check-ignore: demo copy (not localized yet)
        Text('Applicant: ${detail.applicant['name']}'),
        // check-ignore: demo copy (not localized yet)
        Text('Business: ${detail.business['name']}'),
        Text(
          // check-ignore: demo copy (not localized yet)
          'Loan: ${detail.loan['amount']} • ${detail.loan['purpose']}',
        ),
        const SizedBox(height: 8),
        // check-ignore: demo copy (not localized yet)
        Text('Risk signals (${detail.riskSignals.length})'),
        ...detail.riskSignals
            .take(6)
            .map(
              (final signal) => Text(
                // check-ignore: demo copy (not localized yet)
                '- ${signal['label']}: ${signal['value']} (${signal['severity']})',
              ),
            ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AiDecisionRunButton extends StatelessWidget {
  const _AiDecisionRunButton({required this.onRunDecisionSupport});

  final void Function(BuildContext context) onRunDecisionSupport;

  @override
  Widget build(final BuildContext context) {
    final runState = context
        .selectState<
          AiDecisionCubit,
          AiDecisionState,
          ({bool isRunningDecision, bool hasCaseDetail})
        >(
          selector: (final state) => (
            isRunningDecision: state.isRunningDecision,
            hasCaseDetail: state.caseDetail != null,
          ),
        );

    return FilledButton(
      onPressed: runState.isRunningDecision || !runState.hasCaseDetail
          ? null
          : () => onRunDecisionSupport(context),
      child: runState.isRunningDecision
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Run decision support'),
    );
  }
}

class _AiDecisionDecisionSection extends StatelessWidget {
  const _AiDecisionDecisionSection({
    required this.bandColor,
    required this.pillBuilder,
  });

  final Color Function(ColorScheme colors, String band) bandColor;
  final Widget Function({
    required BuildContext context,
    required String label,
    required Color color,
  })
  pillBuilder;

  @override
  Widget build(final BuildContext context) {
    final decision = context
        .selectState<
          AiDecisionCubit,
          AiDecisionState,
          AiDecisionDecisionResult?
        >(
          selector: (final state) =>
              state.decision ?? state.caseDetail?.latestDecision,
        );

    if (decision == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          // check-ignore: demo copy (not localized yet)
          'Risk score',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              decision.riskScore.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            pillBuilder(
              context: context,
              label: decision.riskBand.toUpperCase(),
              color: bandColor(
                Theme.of(context).colorScheme,
                decision.riskBand,
              ),
            ),
            pillBuilder(
              context: context,
              // check-ignore: demo copy (not localized yet)
              label: 'Action: ${decision.recommendedAction}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          // check-ignore: demo copy (not localized yet)
          'Rationale',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Text(decision.rationale),
        const SizedBox(height: 16),
        Text(
          // check-ignore: demo copy (not localized yet)
          'Proof',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        buildAiDecisionProofPanel(
          context: context,
          proof: decision.proof,
          pill: pillBuilder,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AiDecisionActionButtons extends StatelessWidget {
  const _AiDecisionActionButtons({required this.actionNote});

  final TextEditingController actionNote;

  @override
  Widget build(final BuildContext context) {
    final actionState = context
        .selectState<
          AiDecisionCubit,
          AiDecisionState,
          ({bool isSavingAction, bool hasCaseDetail})
        >(
          selector: (final state) => (
            isSavingAction: state.isSavingAction,
            hasCaseDetail: state.caseDetail != null,
          ),
        );

    return Wrap(
      spacing: 8,
      children: <Widget>[
        for (final actionType in const <String>[
          'approve',
          'manual_review',
          'request_docs',
          'decline',
        ])
          FilledButton.tonal(
            onPressed: actionState.isSavingAction || !actionState.hasCaseDetail
                ? null
                : () => unawaited(
                    context.cubit<AiDecisionCubit>().saveAction(
                      actionType: actionType,
                      note: actionNote.text,
                    ),
                  ),
            child: Text(actionType),
          ),
      ],
    );
  }
}

class _AiDecisionActionHistorySection extends StatelessWidget {
  const _AiDecisionActionHistorySection();

  @override
  Widget build(final BuildContext context) {
    final detail = context
        .selectState<AiDecisionCubit, AiDecisionState, AiDecisionCaseDetail?>(
          selector: (final state) => state.caseDetail,
        );

    if (detail == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // check-ignore: demo copy (not localized yet)
        Text('Action history (${detail.actions.length})'),
        ...detail.actions
            .take(8)
            .map(
              (final action) =>
                  // check-ignore: demo copy (not localized yet)
                  Text('- ${action['action_type']}: ${action['note']}'),
            ),
      ],
    );
  }
}
