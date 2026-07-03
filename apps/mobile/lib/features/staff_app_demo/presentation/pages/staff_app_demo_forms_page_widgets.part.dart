part of 'staff_app_demo_forms_page.dart';

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

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final start = StaffDemoWeekCalendar.weekStartUtc();
    final days = StaffDemoWeekCalendar.weekDaysUtc(start);

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
              alignment: AlignmentDirectional.centerEnd,
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
              alignment: AlignmentDirectional.centerEnd,
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
