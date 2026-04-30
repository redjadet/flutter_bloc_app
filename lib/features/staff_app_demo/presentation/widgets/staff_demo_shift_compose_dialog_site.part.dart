part of 'staff_demo_shift_compose_dialog.dart';

class _ShiftComposeSiteDropdown extends StatelessWidget {
  const _ShiftComposeSiteDropdown({
    required this.selectedSiteId,
    required this.onChanged,
  });

  final String? selectedSiteId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final sitesState = context.watch<StaffDemoSitesCubit>().state;
    final List<StaffDemoSite> sites = sitesState.sites;

    final effectiveSelectedSiteId =
        selectedSiteId ?? (sites.isEmpty ? null : sites.first.siteId);

    return DropdownButtonFormField<String>(
      key: ValueKey<String>(
        'staffDemo.shiftAssignment.sitePicker.$effectiveSelectedSiteId',
      ),
      initialValue: effectiveSelectedSiteId,
      items: sites
          .map(
            (final s) => DropdownMenuItem<String>(
              value: s.siteId,
              child: Text('${s.name} (${s.siteId})'),
            ),
          )
          .toList(),
      onChanged: sites.isEmpty ? null : onChanged,
      decoration: InputDecoration(
        labelText: l10n.staffDemoSitePickerLabel,
        helperText: sitesState.status == StaffDemoSitesStatus.loading
            ? l10n.staffDemoSitePickerLoading
            : sitesState.status == StaffDemoSitesStatus.error
            ? (sitesState.errorMessage ?? l10n.staffDemoSitePickerFailed)
            : sites.isEmpty
            ? l10n.staffDemoSitePickerEmpty
            : null,
      ),
    );
  }
}
