import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_state.dart';
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
      body: switch (state.status) {
        StaffDemoMessagesStatus.initial ||
        StaffDemoMessagesStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        StaffDemoMessagesStatus.error => CommonErrorView(
          message: state.errorMessage ?? 'Unknown error.',
        ),
        StaffDemoMessagesStatus.ready => Column(
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
            Expanded(
              child: state.items.isEmpty
                  ? const Center(child: Text('No messages yet.'))
                  : ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _InboxTile(item: state.items[index]),
                    ),
            ),
          ],
        ),
      },
    );
  }

  Future<void> _showComposeDialog(final BuildContext context) async {
    final toController = TextEditingController();
    final siteController = TextEditingController(text: 'site1');
    final bodyController = TextEditingController(
      text: 'Your shift starts at 10:00. Please meet at the warehouse.',
    );

    final now = DateTime.now().toUtc();
    final start = now.add(const Duration(minutes: 30));
    final end = start.add(const Duration(hours: 4));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send shift assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: toController,
              decoration: const InputDecoration(labelText: 'Recipient userId'),
            ),
            TextField(
              controller: siteController,
              decoration: const InputDecoration(labelText: 'Site ID'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Message body'),
              maxLines: 3,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (result != true) return;
    final toUserId = toController.text.trim();
    if (toUserId.isEmpty) return;

    await context.cubit<StaffDemoMessagesCubit>().sendShiftAssignment(
      toUserId: toUserId,
      body: bodyController.text.trim(),
      siteId: siteController.text.trim(),
      startAtUtc: start,
      endAtUtc: end,
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
