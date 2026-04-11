import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/sites/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoMessagesPage extends StatelessWidget {
  const StaffAppDemoMessagesPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final role = context.select<StaffDemoSessionCubit, StaffDemoRole?>(
      (final c) => c.state.profile?.role,
    );
    final bool canCompose =
        role == StaffDemoRole.manager || role == StaffDemoRole.accountant;

    final state = context.watch<StaffDemoMessagesCubit>().state;

    return CommonPageLayout(
      title: 'Messages',
      body: RefreshIndicator(
        onRefresh: context.read<StaffDemoMessagesCubit>().initialize,
        child: switch (state.status) {
          StaffDemoMessagesStatus.initial ||
          StaffDemoMessagesStatus.loading => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          StaffDemoMessagesStatus.error => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 240,
                child: CommonErrorView(
                  message: state.errorMessage ?? 'Unknown error.',
                ),
              ),
            ],
          ),
          StaffDemoMessagesStatus.ready => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              if (canCompose)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () => _showComposeDialog(context),
                    icon: const Icon(Icons.send),
                    label: const Text('Send shift assignment'),
                  ),
                ),
              if (state.items.isEmpty)
                const SizedBox(
                  height: 240,
                  child: Center(child: Text('No messages yet.')),
                )
              else
                ...List<Widget>.generate(state.items.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    return const Divider(height: 1);
                  }
                  final messageIndex = index ~/ 2;
                  return _InboxTile(item: state.items[messageIndex]);
                }),
            ],
          ),
        },
      ),
    );
  }

  Future<void> _showComposeDialog(final BuildContext context) async {
    final recipientController = TextEditingController();
    final bodyController = TextEditingController(
      text: 'Your shift starts at 10:00. Please meet at the warehouse.',
    );

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

    String? selectedUserId;
    String? selectedSiteId;
    final StaffDemoSitesCubit sitesCubit = context.cubit<StaffDemoSitesCubit>();
    final result = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: sitesCubit,
        child: FutureBuilder<List<StaffDemoProfile>>(
          future: staffFuture,
          builder: (context, snapshot) {
            final staff = snapshot.data ?? const <StaffDemoProfile>[];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;
            final errorText = snapshot.error?.toString();

            return StatefulBuilder(
              builder: (context, setState) {
                final bool canSelectFromList = !isLoading && !hasError && staff.isNotEmpty;
                final bool showManualUserId = !isLoading && staff.isEmpty;
                final String manualUserId = recipientController.text.trim();
                final String? selectedTrimmed = selectedUserId?.trim();
                final String? effectiveUserId =
                    (selectedTrimmed != null && selectedTrimmed.isNotEmpty)
                    ? selectedTrimmed
                    : (manualUserId.isNotEmpty ? manualUserId : null);

                final sitesState = context.watch<StaffDemoSitesCubit>().state;
                final String? selectedSiteTrimmed = selectedSiteId?.trim();
                final String? effectiveSiteId =
                    (selectedSiteTrimmed != null && selectedSiteTrimmed.isNotEmpty)
                    ? selectedSiteTrimmed
                    : (sitesState.sites.isEmpty ? null : sitesState.sites.first.siteId);

                return AlertDialog(
                  title: const Text('Send shift assignment'),
                  content: Column(
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
                                ? 'Failed to load staff list.'
                                : 'Failed to load staff list.\n$errorText',
                          ),
                        ),
                      if (canSelectFromList)
                        DropdownButtonFormField<String>(
                          initialValue: selectedUserId,
                          isExpanded: true,
                          items: staff
                              .map(
                                (p) => DropdownMenuItem<String>(
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
                          selectedItemBuilder: (context) => staff
                              .map(
                                (p) => Align(
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
                          onChanged: (value) => setState(() {
                            selectedUserId = value?.trim();
                            recipientController.text = '';
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Assign to staff',
                          ),
                        ),
                      if (canSelectFromList) const SizedBox(height: 12),
                      if (showManualUserId) ...[
                        TextField(
                          key: const Key(
                            'staffDemo.shiftAssignment.recipientUserId',
                          ),
                          controller: recipientController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Recipient userId',
                            helperText: 'Enter a Firebase Auth uid.',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _SiteDropdown(
                        selectedSiteId: selectedSiteId,
                        onChanged: (value) => setState(() {
                          selectedSiteId = value;
                        }),
                      ),
                      TextField(
                        key: const Key('staffDemo.shiftAssignment.body'),
                        controller: bodyController,
                        decoration: const InputDecoration(
                          labelText: 'Message body',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: effectiveUserId == null || effectiveSiteId == null
                          ? null
                          : () => Navigator.of(context).pop(effectiveUserId),
                      child: const Text('Send'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );

    if (!context.mounted) return;
    final toUserId = result?.trim();
    if (toUserId == null || toUserId.isEmpty) return;
    final sitesState = context.cubit<StaffDemoSitesCubit>().state;
    final String? selectedSiteTrimmedAfterDialog = selectedSiteId?.trim();
    final String? siteId =
        (selectedSiteTrimmedAfterDialog != null && selectedSiteTrimmedAfterDialog.isNotEmpty)
        ? selectedSiteTrimmedAfterDialog
        : (sitesState.sites.isEmpty ? null : sitesState.sites.first.siteId);
    if (siteId == null || siteId.isEmpty) return;

    await context.cubit<StaffDemoMessagesCubit>().sendShiftAssignment(
      toUserId: toUserId,
      body: bodyController.text.trim(),
      siteId: siteId,
      startAtUtc: defaultStartUtc,
      endAtUtc: defaultEndUtc,
    );
  }
}

class _SiteDropdown extends StatelessWidget {
  const _SiteDropdown({
    required this.selectedSiteId,
    required this.onChanged,
  });

  final String? selectedSiteId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(final BuildContext context) {
    final sitesState = context.watch<StaffDemoSitesCubit>().state;
    final List<StaffDemoSite> sites = sitesState.sites;

    final effectiveSelectedSiteId = selectedSiteId ?? (sites.isEmpty ? null : sites.first.siteId);

    return DropdownButtonFormField<String>(
      key: ValueKey<String>(
        'staffDemo.shiftAssignment.sitePicker.$effectiveSelectedSiteId',
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
      onChanged: sites.isEmpty ? null : onChanged,
      decoration: InputDecoration(
        labelText: 'Site',
        helperText: sitesState.status == StaffDemoSitesStatus.loading
            ? 'Loading sites...'
            : sitesState.status == StaffDemoSitesStatus.error
            ? (sitesState.errorMessage ?? 'Failed to load sites.')
            : sites.isEmpty
            ? 'No sites found in staffDemoSites.'
            : null,
      ),
    );
  }
}

class _InboxTile extends StatelessWidget {
  const _InboxTile({required this.item});

  final StaffDemoInboxItem item;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      title: Text(item.type.isEmpty ? 'Message' : item.type),
      subtitle: Text(item.body),
      trailing: item.shiftId == null
          ? null
          : item.isConfirmed
          ? const Text('Confirmed')
          : FilledButton(
              onPressed: () =>
                  context.cubit<StaffDemoMessagesCubit>().confirm(item),
              child: const Text('Confirm'),
            ),
    );
  }
}
