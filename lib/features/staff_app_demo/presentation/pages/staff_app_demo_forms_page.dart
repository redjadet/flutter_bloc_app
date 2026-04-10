// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_state.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoFormsPage extends StatelessWidget {
  const StaffAppDemoFormsPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoFormsCubit>().state;

    return CommonPageLayout(
      title: 'Forms',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _StatusBanner(state: state),
          const SizedBox(height: 16),
          const _AvailabilityCard(),
          const SizedBox(height: 16),
          const _ManagerReportCard(),
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
    final String? message = switch (state.status) {
      StaffDemoFormsStatus.initial => null,
      StaffDemoFormsStatus.submitting => 'Submitting…',
      StaffDemoFormsStatus.success => state.lastSubmitLabel ?? 'Submitted.',
      StaffDemoFormsStatus.error => state.errorMessage ?? 'Failed.',
    };
    if (message == null) return const SizedBox.shrink();

    final Color bg = switch (state.status) {
      StaffDemoFormsStatus.success => Colors.green.withValues(alpha: 0.12),
      StaffDemoFormsStatus.error => Colors.red.withValues(alpha: 0.12),
      _ => Colors.blue.withValues(alpha: 0.10),
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
    final start = _weekStartUtc();
    final days = _weekDaysUtc(start);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Weekly availability',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                child: const Text('Submit availability'),
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
  final _siteIdController = TextEditingController(text: 'site1');
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _siteIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Manager report',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _siteIdController,
            decoration: const InputDecoration(labelText: 'Site ID'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
            minLines: 3,
            maxLines: 8,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                await context.cubit<StaffDemoFormsCubit>().submitManagerReport(
                  siteId: _siteIdController.text,
                  notes: _notesController.text,
                );
                if (!context.mounted) return;
                _notesController.clear();
              },
              child: const Text('Submit report'),
            ),
          ),
        ],
      ),
    ),
  );
}
