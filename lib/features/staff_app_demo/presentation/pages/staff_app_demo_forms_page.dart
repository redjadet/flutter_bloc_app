// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/sites/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/staff_demo_presentation_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoFormsPage extends StatelessWidget {
  const StaffAppDemoFormsPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoFormsCubit>().state;
    final l10n = context.l10n;
    final bool pinBanner =
        staffDemoFormsStatusBannerMessage(l10n, state) != null;

    return CommonPageLayout(
      title: l10n.staffDemoFormsTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (pinBanner)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _StatusBanner(state: state),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: const <Widget>[
                _AvailabilityCard(),
                SizedBox(height: 16),
                _ManagerReportCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state});

  final StaffDemoFormsState state;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final String? message = staffDemoFormsStatusBannerMessage(l10n, state);
    if (message == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final Color bg = switch (state.status) {
      StaffDemoFormsStatus.success => colorScheme.primaryContainer,
      StaffDemoFormsStatus.error => colorScheme.errorContainer,
      _ => colorScheme.surfaceContainerHighest,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    );
  }
}

class _AvailabilityCard extends StatefulWidget {
  const _AvailabilityCard();

  @override
  State<_AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<_AvailabilityCard> {
  final Map<String, bool> _availability = <String, bool>{};

  DateTime _weekStartUtc() {
    final now = DateTime.now().toUtc();
    final day = now.weekday; // Mon=1..Sun=7
    final start = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: day - 1));
    return start;
  }

  List<DateTime> _weekDaysUtc(final DateTime weekStartUtc) =>
      List<DateTime>.generate(
        7,
        (i) => weekStartUtc.add(Duration(days: i)),
        growable: false,
      );

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final start = _weekStartUtc();
    final days = _weekDaysUtc(start);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.staffDemoFormsWeeklyAvailability,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...days.map((d) {
              final iso = d.toIso8601String().substring(0, 10);
              final value = _availability[iso] ?? false;
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(iso),
                value: value,
                onChanged: (v) => setState(() => _availability[iso] = v),
              );
            }),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () async {
                  await context.cubit<StaffDemoFormsCubit>().submitAvailability(
                    weekStartUtc: start,
                    availabilityByIsoDate: Map<String, bool>.from(
                      _availability,
                    ),
                  );
                },
                child: Text(l10n.staffDemoFormsSubmitAvailability),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerReportCard extends StatefulWidget {
  const _ManagerReportCard();

  @override
  State<_ManagerReportCard> createState() => _ManagerReportCardState();
}

class _ManagerReportCardState extends State<_ManagerReportCard> {
  final _notesController = TextEditingController();
  String? _selectedSiteId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.staffDemoFormsManagerReport,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final sitesState = context.watch<StaffDemoSitesCubit>().state;
                final List<StaffDemoSite> sites = sitesState.sites;
                final effectiveSelectedSiteId =
                    _selectedSiteId ??
                    (sites.isEmpty ? null : sites.first.siteId);

                return DropdownButtonFormField<String>(
                  key: ValueKey<String>(
                    'staffDemo.forms.managerReport.sitePicker.$effectiveSelectedSiteId',
                  ),
                  initialValue: effectiveSelectedSiteId,
                  items: sites
                      .map(
                        (s) => DropdownMenuItem<String>(
                          value: s.siteId,
                          child: Text('${s.name} (${s.siteId})'),
                        ),
                      )
                      .toList(),
                  onChanged: sites.isEmpty
                      ? null
                      : (value) => setState(() => _selectedSiteId = value),
                  decoration: InputDecoration(
                    labelText: l10n.staffDemoSitePickerLabel,
                    helperText:
                        sitesState.status == StaffDemoSitesStatus.loading
                        ? l10n.staffDemoSitePickerLoading
                        : sitesState.status == StaffDemoSitesStatus.error
                        ? (sitesState.errorMessage ??
                              l10n.staffDemoSitePickerFailed)
                        : sites.isEmpty
                        ? l10n.staffDemoSitePickerEmpty
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.staffDemoFormsNotesLabel,
              ),
              minLines: 3,
              maxLines: 8,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () async {
                  final sitesState = context.cubit<StaffDemoSitesCubit>().state;
                  final List<StaffDemoSite> sites = sitesState.sites;
                  final siteId =
                      _selectedSiteId ??
                      (sites.isEmpty ? null : sites.first.siteId);
                  if (siteId == null || siteId.trim().isEmpty) return;

                  await context
                      .cubit<StaffDemoFormsCubit>()
                      .submitManagerReport(
                        siteId: siteId,
                        notes: _notesController.text,
                      );
                  if (!context.mounted) return;
                  final formsState = context.cubit<StaffDemoFormsCubit>().state;
                  if (formsState.status == StaffDemoFormsStatus.success &&
                      formsState.lastSuccessKind ==
                          StaffDemoFormsSuccessKind.managerReportSubmitted) {
                    _notesController.clear();
                  }
                },
                child: Text(l10n.staffDemoFormsSubmitReport),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
