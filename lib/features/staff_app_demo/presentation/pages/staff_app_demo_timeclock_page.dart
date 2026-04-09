import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/timeclock/staff_demo_timeclock_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/timeclock/staff_demo_timeclock_state.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoTimeclockPage extends StatelessWidget {
  const StaffAppDemoTimeclockPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoTimeclockCubit>().state;
    final last = state.lastResult;

    final Widget body = switch (state.status) {
      StaffDemoTimeclockStatus.initial ||
      StaffDemoTimeclockStatus.busy => const Center(
        child: CircularProgressIndicator(),
      ),
      StaffDemoTimeclockStatus.error => CommonErrorView(
        message: state.errorMessage ?? 'Unknown error.',
      ),
      _ => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            state.openEntryId == null
                ? 'Status: clocked out'
                : 'Status: clocked in (${state.openEntryId})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: state.openEntryId == null
                      ? () => context.cubit<StaffDemoTimeclockCubit>().clockIn()
                      : null,
                  child: const Text('Clock in'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: state.openEntryId != null
                      ? () =>
                            context.cubit<StaffDemoTimeclockCubit>().clockOut()
                      : null,
                  child: const Text('Clock out'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (last != null) ...<Widget>[
            Text(
              'Last result flags:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(last.flags.toJson().toString()),
            if (last.distanceMeters != null && last.radiusMeters != null) ...[
              const SizedBox(height: 8),
              Text(
                'Distance: ${last.distanceMeters!.toStringAsFixed(1)}m '
                '(radius ${last.radiusMeters!.toStringAsFixed(1)}m)',
              ),
            ],
          ],
        ],
      ),
    };

    return CommonPageLayout(
      title: 'Timeclock',
      body: body,
    );
  }
}
