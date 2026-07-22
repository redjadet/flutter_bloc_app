import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

class OnlineTherapyDemoClientTherapistsPage extends StatefulWidget {
  const OnlineTherapyDemoClientTherapistsPage({super.key});

  @override
  State<OnlineTherapyDemoClientTherapistsPage> createState() =>
      _OnlineTherapyDemoClientTherapistsPageState();
}

class _OnlineTherapyDemoClientTherapistsPageState
    extends State<OnlineTherapyDemoClientTherapistsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.cubit<ClientBookingCubit>().loadTherapists());
    });
  }

  @override
  Widget build(final BuildContext context) {
    final isBusy = context
        .selectState<ClientBookingCubit, ClientBookingState, bool>(
          selector: (final state) => state.isBusy,
        );
    final _VerifiedTherapistsViewData verifiedTherapists = context
        .selectState<
          ClientBookingCubit,
          ClientBookingState,
          _VerifiedTherapistsViewData
        >(
          selector: _VerifiedTherapistsViewData.fromState,
        );
    final cubit = context.cubit<ClientBookingCubit>();

    return CommonPageLayout(
      title: 'Therapists',
      body: RefreshIndicator(
        onRefresh: cubit.loadTherapists,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: verifiedTherapists.items.length + 1,
          separatorBuilder: (final context, final index) =>
              const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return KeyedSubtree(
                key: const ValueKey('online-therapy-client-therapists-header'),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    isBusy ? 'Loading…' : 'Select a therapist to view details.',
                  ),
                ),
              );
            }

            final t = verifiedTherapists.items[index - 1];
            return ListTile(
              key: ValueKey<String>('online-therapy-therapist-${t.id}'),
              title: Text(
                t.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Rating: ${t.rating.toStringAsFixed(1)} • ${t.specialties.take(2).join(', ')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: isBusy
                  ? null
                  : () async {
                      await cubit.selectTherapist(t.id);
                      if (!context.mounted) return;
                      await context.pushNamed(
                        AppRoutes.onlineTherapyDemoClientTherapistDetail,
                        pathParameters: <String, String>{'therapistId': t.id},
                      );
                    },
            );
          },
        ),
      ),
    );
  }
}

@immutable
class _VerifiedTherapistsViewData {
  const _VerifiedTherapistsViewData(this.items);

  factory _VerifiedTherapistsViewData.fromState(
    final ClientBookingState state,
  ) {
    final items = <TherapistProfile>[
      for (final therapist in state.therapists)
        if (therapist.isVerified) therapist,
    ];
    return _VerifiedTherapistsViewData(
      List<TherapistProfile>.unmodifiable(items),
    );
  }

  final List<TherapistProfile> items;

  static const DeepCollectionEquality _eq = DeepCollectionEquality();

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is _VerifiedTherapistsViewData && _eq.equals(other.items, items);

  @override
  int get hashCode => _eq.hash(items);
}

// eof
// end
//
