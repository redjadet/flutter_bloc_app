part of 'staff_demo_shift_compose_dialog.dart';

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
                    key: const Key(
                      'staffDemo.shiftAssignment.recipientDropdown',
                    ),
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
                            alignment: AlignmentDirectional.centerStart,
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
