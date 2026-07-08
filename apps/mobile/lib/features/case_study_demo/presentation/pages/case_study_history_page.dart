import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/utils/error_handling.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_data_mode_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CaseStudyHistoryPage extends StatelessWidget {
  const CaseStudyHistoryPage({super.key});

  Future<bool> _confirmDelete(final BuildContext context) async {
    final l10n = context.l10n;
    final bool? confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (final dialogContext) => AlertDialog.adaptive(
        title: Text(l10n.caseStudyDeleteDialogTitle),
        content: Text(l10n.caseStudyDeleteDialogBody),
        actions: [
          TextButton(
            onPressed: () {
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(l10n.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop(true);
            },
            child: Text(l10n.deleteButtonLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return TypeSafeBlocListener<CaseStudyHistoryCubit, CaseStudyHistoryState>(
      listenWhen: (final prev, final curr) =>
          prev.transientError != curr.transientError &&
          curr.transientError != null,
      listener: (final context, final state) {
        final Object? error = state.transientError;
        if (error == null) return;
        ErrorHandling.handleCubitError(context, error);
        context.cubit<CaseStudyHistoryCubit>().clearTransientError();
      },
      child: CommonPageLayout(
        title: l10n.caseStudyHistoryTitle,
        body: TypeSafeBlocBuilder<CaseStudyHistoryCubit, CaseStudyHistoryState>(
          builder: (final context, final state) {
            if (state.isLoading && state.records.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CaseStudyHistoryStatus.error &&
                state.records.isEmpty) {
              return Center(
                child: Text(
                  state.errorMessage ?? l10n.caseStudyHistoryEmpty,
                ),
              );
            }

            final List<CaseStudyRecord> records = state.records;
            if (records.isEmpty) {
              return Center(child: Text(l10n.caseStudyHistoryEmpty));
            }

            final DateFormat fmt = DateFormat.yMMMd().add_jm();
            return RefreshIndicator(
              onRefresh: () => context.cubit<CaseStudyHistoryCubit>().refresh(),
              child: ListView.separated(
                itemCount: records.length + 1,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return KeyedSubtree(
                      key: const ValueKey('case-study-history-header'),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: CaseStudyDataModeBadge(mode: state.dataMode),
                        ),
                      ),
                    );
                  }
                  final int recordIndex = i - 1;
                  final CaseStudyRecord r = records[recordIndex];
                  return ListTile(
                    key: ValueKey<String>('case-study-record-${r.id}'),
                    title: Text(r.doctorName),
                    subtitle: Text(
                      '${caseStudyCaseTypeTitle(l10n, r.caseType)} · ${fmt.format(r.submittedAt.toLocal())}',
                    ),
                    trailing: IconButton(
                      tooltip: l10n.deleteButtonLabel,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: state.deletingRecordId == r.id
                          ? null
                          : () async {
                              final bool shouldDelete = await _confirmDelete(
                                context,
                              );
                              if (!shouldDelete || !context.mounted) return;
                              await context
                                  .cubit<CaseStudyHistoryCubit>()
                                  .deleteRecord(recordId: r.id);
                            },
                    ),
                    onTap: () => context.pushNamed(
                      AppRoutes.caseStudyDemoHistoryDetail,
                      pathParameters: <String, String>{'id': r.id},
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
