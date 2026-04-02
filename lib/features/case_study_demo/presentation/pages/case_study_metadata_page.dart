// check-ignore: nonbuilder_lists - small, fixed-size form
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:go_router/go_router.dart';

class CaseStudyMetadataPage extends StatelessWidget {
  const CaseStudyMetadataPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.caseStudyDemoMetadataTitle,
      body: BlocBuilder<CaseStudySessionCubit, CaseStudySessionState>(
        builder: (context, state) {
          if (state.hydration != CaseStudyHydrationStatus.ready) {
            return const Center(child: CircularProgressIndicator());
          }
          return _MetadataForm(
            key: ValueKey<String>(state.draft.caseId),
            initialDoctor: state.draft.doctorName,
            initialNotes: state.draft.notes,
            initialCaseType: state.draft.caseType,
          );
        },
      ),
    );
  }
}

class _MetadataForm extends StatefulWidget {
  const _MetadataForm({
    required super.key,
    required this.initialDoctor,
    required this.initialNotes,
    required this.initialCaseType,
  });

  final String initialDoctor;
  final String initialNotes;
  final CaseStudyCaseType? initialCaseType;

  @override
  State<_MetadataForm> createState() => _MetadataFormState();
}

class _MetadataFormState extends State<_MetadataForm> {
  late final TextEditingController _doctor = TextEditingController(
    text: widget.initialDoctor,
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.initialNotes,
  );
  CaseStudyCaseType? _caseType;

  @override
  void initState() {
    super.initState();
    _caseType = widget.initialCaseType;
  }

  @override
  void dispose() {
    _doctor.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        TextField(
          controller: _doctor,
          decoration: InputDecoration(labelText: l10n.caseStudyDoctorNameLabel),
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CaseStudyCaseType>(
          initialValue: _caseType,
          decoration: InputDecoration(labelText: l10n.caseStudyCaseTypeLabel),
          items: CaseStudyCaseType.values
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(caseStudyCaseTypeTitle(l10n, t)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _caseType = v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notes,
          decoration: InputDecoration(labelText: l10n.caseStudyNotesLabel),
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _caseType == null || _doctor.text.trim().isEmpty
              ? null
              : () async {
                  final CaseStudyCaseType? selected = _caseType;
                  if (selected == null) return;
                  await context.cubit<CaseStudySessionCubit>().setMetadata(
                    doctorName: _doctor.text.trim(),
                    caseType: selected,
                    notes: _notes.text.trim(),
                  );
                  if (context.mounted) {
                    context.goNamed(AppRoutes.caseStudyDemoRecord);
                  }
                },
          child: Text(l10n.caseStudyContinue),
        ),
      ],
    );
  }
}
