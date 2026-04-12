import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/sites/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

/// Values collected when the user confirms shift assignment in the compose dialog.
class _StaffDemoShiftComposeResult {
  const _StaffDemoShiftComposeResult({
    required this.toUserId,
    required this.body,
    required this.siteId,
  });

  final String toUserId;
  final String body;
  final String siteId;
}

/// Manager/accountant shift assignment compose flow (Firestore-backed demo).
Future<void> showStaffDemoShiftComposeDialog(final BuildContext context) async {
  final l10n = context.l10n;
  final DateTime defaultStartUtc = DateTime.now().toUtc().add(
    const Duration(minutes: 30),
  );
  final DateTime defaultEndUtc = defaultStartUtc.add(
    const Duration(hours: 4),
  );

  final StaffDemoProfileRepository profileRepository =
      getIt<StaffDemoProfileRepository>();
  final Future<List<StaffDemoProfile>> staffFuture = profileRepository
      .listAssignableStaff();

  final StaffDemoSitesCubit sitesCubit = context.cubit<StaffDemoSitesCubit>();

  final _StaffDemoShiftComposeResult? result =
      await showDialog<_StaffDemoShiftComposeResult>(
        context: context,
        builder: (final dialogContext) => BlocProvider.value(
          value: sitesCubit,
          child: _StaffDemoShiftComposeDialog(
            staffFuture: staffFuture,
            defaultBodyText: l10n.staffDemoComposeDefaultShiftBody,
          ),
        ),
      );

  if (!context.mounted) return;
  if (result == null) return;

  await context.cubit<StaffDemoMessagesCubit>().sendShiftAssignment(
    toUserId: result.toUserId,
    body: result.body,
    siteId: result.siteId,
    startAtUtc: defaultStartUtc,
    endAtUtc: defaultEndUtc,
  );
}

class _StaffDemoShiftComposeDialog extends StatefulWidget {
  const _StaffDemoShiftComposeDialog({
    required this.staffFuture,
    required this.defaultBodyText,
  });

  final Future<List<StaffDemoProfile>> staffFuture;
  final String defaultBodyText;

  @override
  State<_StaffDemoShiftComposeDialog> createState() =>
      _StaffDemoShiftComposeDialogState();
}

class _StaffDemoShiftComposeDialogState
    extends State<_StaffDemoShiftComposeDialog> {
  late final TextEditingController _recipientController;
  late final TextEditingController _bodyController;
  String? _selectedUserId;
  String? _selectedSiteId;

  @override
  void initState() {
    super.initState();
    _recipientController = TextEditingController();
    _bodyController = TextEditingController(text: widget.defaultBodyText);
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<List<StaffDemoProfile>>(
      future: widget.staffFuture,
      builder: (final context, final snapshot) {
        final staff = snapshot.data ?? const <StaffDemoProfile>[];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final errorText = snapshot.error?.toString();

        final bool canSelectFromList =
            !isLoading && !hasError && staff.isNotEmpty;
        final bool showManualUserId = !isLoading && staff.isEmpty;
        final String manualUserId = _recipientController.text.trim();
        final String? selectedTrimmed = _selectedUserId?.trim();
        final String? effectiveUserId =
            (selectedTrimmed != null && selectedTrimmed.isNotEmpty)
            ? selectedTrimmed
            : (manualUserId.isNotEmpty ? manualUserId : null);

        final sitesState = context.watch<StaffDemoSitesCubit>().state;
        final String? selectedSiteTrimmed = _selectedSiteId?.trim();
        final String? effectiveSiteId =
            (selectedSiteTrimmed != null && selectedSiteTrimmed.isNotEmpty)
            ? selectedSiteTrimmed
            : (sitesState.sites.isEmpty ? null : sitesState.sites.first.siteId);

        void onSend() {
          final toUserId = effectiveUserId?.trim();
          final siteId = effectiveSiteId?.trim();
          if (toUserId == null ||
              toUserId.isEmpty ||
              siteId == null ||
              siteId.isEmpty) {
            return;
          }
          Navigator.of(context).pop(
            _StaffDemoShiftComposeResult(
              toUserId: toUserId,
              body: _bodyController.text.trim(),
              siteId: siteId,
            ),
          );
        }

        return AlertDialog(
          title: Text(l10n.staffDemoComposeTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      errorText == null
                          ? l10n.staffDemoComposeStaffListFailed
                          : l10n.staffDemoComposeStaffListFailedWithDetails(
                              errorText,
                            ),
                    ),
                  ),
                if (canSelectFromList)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUserId,
                    isExpanded: true,
                    items: staff
                        .map(
                          (final p) => DropdownMenuItem<String>(
                            value: p.userId,
                            child: Text(
                              p.email.trim().isEmpty
                                  ? p.displayName
                                  : '${p.displayName} (${p.email})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (final context) => staff
                        .map(
                          (final p) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              p.email.trim().isEmpty
                                  ? p.displayName
                                  : '${p.displayName} (${p.email})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (final value) => setState(() {
                      _selectedUserId = value?.trim();
                      _recipientController.text = '';
                    }),
                    decoration: InputDecoration(
                      labelText: l10n.staffDemoAssignToStaffLabel,
                    ),
                  ),
                if (canSelectFromList) const SizedBox(height: 12),
                if (showManualUserId) ...[
                  TextField(
                    key: const Key('staffDemo.shiftAssignment.recipientUserId'),
                    controller: _recipientController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.staffDemoComposeRecipientUserId,
                      helperText: l10n.staffDemoComposeRecipientUserIdHelper,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _ShiftComposeSiteDropdown(
                  selectedSiteId: _selectedSiteId,
                  onChanged: (final value) => setState(() {
                    _selectedSiteId = value;
                  }),
                ),
                TextField(
                  key: const Key('staffDemo.shiftAssignment.body'),
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: l10n.staffDemoComposeMessageBodyLabel,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.todoListCancelAction),
            ),
            FilledButton(
              onPressed: effectiveUserId == null || effectiveSiteId == null
                  ? null
                  : onSend,
              child: Text(l10n.staffDemoActionSend),
            ),
          ],
        );
      },
    );
  }
}

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
