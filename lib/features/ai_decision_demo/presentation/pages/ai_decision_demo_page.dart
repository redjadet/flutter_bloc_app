// check-ignore: nonbuilder_lists - small, fixed-size page content

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_repository.dart';
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

  @override
  Widget build(final BuildContext context) {
    const title = 'AI Decision Workbench';
    return BlocProviderHelpers.withAsyncInit<AiDecisionCubit>(
      create: () => AiDecisionCubit(repository: getIt<AiDecisionRepository>()),
      init: (final cubit) => cubit.loadQueue(),
      child: CommonPageLayout(
        title: title,
        body: BlocBuilder<AiDecisionCubit, AiDecisionState>(
          builder: (final context, final state) {
            if (state.isLoadingQueue) {
              return const Center(child: CircularProgressIndicator());
            }

            final error = state.errorMessage;
            if (error != null) {
              return CommonErrorView(message: error);
            }

            if (state.queue.isEmpty) {
              return const Center(
                child: Text('No cases (seed the backend DB).'),
              );
            }

            final selectedId = state.selectedCaseId ?? state.queue.first.id;
            final detail = state.caseDetail;
            final decision = state.decision ?? detail?.latestDecision;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedId,
                    items: state.queue
                        .map(
                          (final c) => DropdownMenuItem<String>(
                            value: c.id,
                            child: Text('${c.id} • ${c.businessName}'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (final v) async {
                      if (v == null) return;
                      await context.cubit<AiDecisionCubit>().loadCase(v);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Case',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (detail != null) ...[
                    Text('Applicant: ${detail.applicant['name']}'),
                    Text('Business: ${detail.business['name']}'),
                    Text(
                      'Loan: ${detail.loan['amount']} • ${detail.loan['purpose']}',
                    ),
                    const SizedBox(height: 8),
                    Text('Risk signals (${detail.riskSignals.length})'),
                    ...detail.riskSignals
                        .take(6)
                        .map(
                          (final s) => Text(
                            '- ${s['label']}: ${s['value']} (${s['severity']})',
                          ),
                        ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _operatorNote,
                    decoration: const InputDecoration(
                      labelText: 'Operator note (optional)',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: state.isRunningDecision
                        ? null
                        : () async => context
                              .cubit<AiDecisionCubit>()
                              .runDecisionSupport(
                                operatorNote: _operatorNote.text,
                              ),
                    child: state.isRunningDecision
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Run decision support'),
                  ),
                  const SizedBox(height: 16),
                  if (decision != null) ...[
                    Text(
                      'Risk score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          decision.riskScore.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        _pill(
                          context: context,
                          label: decision.riskBand.toUpperCase(),
                          color: _bandColor(
                            Theme.of(context).colorScheme,
                            decision.riskBand,
                          ),
                        ),
                        _pill(
                          context: context,
                          label: 'Action: ${decision.recommendedAction}',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rationale',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(decision.rationale),
                    const SizedBox(height: 16),
                    Text(
                      'Proof',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    buildAiDecisionProofPanel(
                      context: context,
                      proof: decision.proof,
                      pill: _pill,
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Divider(),
                  TextField(
                    controller: _actionNote,
                    decoration: const InputDecoration(
                      labelText: 'Action note',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _actionButton(context, state, 'approve'),
                      _actionButton(context, state, 'manual_review'),
                      _actionButton(context, state, 'request_docs'),
                      _actionButton(context, state, 'decline'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (detail != null) ...[
                    Text('Action history (${detail.actions.length})'),
                    ...detail.actions
                        .take(8)
                        .map(
                          (final a) =>
                              Text('- ${a['action_type']}: ${a['note']}'),
                        ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _actionButton(
    final BuildContext context,
    final AiDecisionState state,
    final String actionType,
  ) => FilledButton.tonal(
    onPressed: state.isSavingAction
        ? null
        : () async => context.cubit<AiDecisionCubit>().saveAction(
            actionType: actionType,
            note: _actionNote.text,
          ),
    child: Text(actionType),
  );
}
