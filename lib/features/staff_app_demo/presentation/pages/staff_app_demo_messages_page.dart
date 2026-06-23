import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/staff_demo_presentation_l10n.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/widgets/staff_demo_shift_compose_dialog.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
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
    final l10n = context.l10n;

    return CommonPageLayout(
      title: l10n.staffDemoMessagesTitle,
      body: RefreshIndicator(
        onRefresh: context.cubit<StaffDemoMessagesCubit>().initialize,
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
                  message: staffDemoMessagesResolvedError(l10n, state),
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
                    onPressed: () => showStaffDemoShiftComposeDialog(context),
                    icon: const Icon(Icons.send),
                    label: Text(l10n.staffDemoComposeSendShiftAssignment),
                  ),
                ),
              if (state.items.isEmpty)
                SizedBox(
                  height: 240,
                  child: Center(child: Text(l10n.staffDemoMessagesEmpty)),
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
}

class _InboxTile extends StatelessWidget {
  const _InboxTile({required this.item});

  final StaffDemoInboxItem item;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      title: Text(
        item.type.isEmpty ? l10n.staffDemoInboxMessageFallback : item.type,
      ),
      subtitle: Text(item.body),
      trailing: item.shiftId == null
          ? null
          : item.isConfirmed
          ? Text(l10n.staffDemoShiftConfirmed)
          : FilledButton(
              onPressed: () =>
                  context.cubit<StaffDemoMessagesCubit>().confirm(item),
              child: Text(l10n.staffDemoShiftConfirmAction),
            ),
    );
  }
}
