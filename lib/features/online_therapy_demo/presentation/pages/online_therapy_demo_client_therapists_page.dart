import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:go_router/go_router.dart';

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
    unawaited(context.cubit<ClientBookingCubit>().loadTherapists());
  }

  @override
  Widget build(final BuildContext context) {
    final state = context.watchBloc<ClientBookingCubit>().state;
    final cubit = context.cubit<ClientBookingCubit>();

    final therapists = state.therapists
        .where((t) => t.isVerified)
        .toList(growable: false);

    return CommonPageLayout(
      title: 'Therapists',
      body: RefreshIndicator(
        onRefresh: cubit.loadTherapists,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: therapists.length + 1,
          separatorBuilder: (final context, final index) =>
              const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return KeyedSubtree(
                key: const ValueKey('online-therapy-client-therapists-header'),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.isBusy
                        ? 'Loading…'
                        : 'Select a therapist to view details.',
                  ),
                ),
              );
            }

            final t = therapists[index - 1];
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
              onTap: state.isBusy
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

// eof
// end
//
