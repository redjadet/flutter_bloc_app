// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/timeclock/staff_demo_timeclock_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/timeclock/staff_demo_timeclock_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoTimeclockPage extends StatelessWidget {
  const StaffAppDemoTimeclockPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoTimeclockCubit>().state;
    final last = state.lastResult;
    final l10n = context.l10n;
    final String? openEntryId = state.openEntryId;

    final Widget body = switch (state.status) {
      StaffDemoTimeclockStatus.initial ||
      StaffDemoTimeclockStatus.busy => const Center(
        child: CircularProgressIndicator(),
      ),
      StaffDemoTimeclockStatus.error => CommonErrorView(
        message: state.errorMessage ?? l10n.errorUnknown,
      ),
      _ => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            openEntryId == null
                ? l10n.staffDemoTimeclockClockedOutStatus
                : l10n.staffDemoTimeclockClockedInStatus(openEntryId),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: openEntryId == null
                      ? () => context.cubit<StaffDemoTimeclockCubit>().clockIn()
                      : null,
                  child: Text(l10n.staffDemoTimeclockClockIn),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: openEntryId != null
                      ? () =>
                            context.cubit<StaffDemoTimeclockCubit>().clockOut()
                      : null,
                  child: Text(l10n.staffDemoTimeclockClockOut),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (last != null) ...<Widget>[
            Text(
              l10n.staffDemoTimeclockLastResultFlags,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(last.flags.toJson().toString()),
            if (last.distanceMeters != null && last.radiusMeters != null) ...[
              const SizedBox(height: 8),
              Builder(
                builder: (ctx) {
                  final distanceMeters = last.distanceMeters;
                  final radiusMeters = last.radiusMeters;
                  if (distanceMeters == null || radiusMeters == null) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    ctx.l10n.staffDemoTimeclockDistanceMeters(
                      distanceMeters.toStringAsFixed(1),
                      radiusMeters.toStringAsFixed(1),
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    };

    return CommonPageLayout(
      title: l10n.staffDemoTimeclockTitle,
      body: body,
    );
  }
}
