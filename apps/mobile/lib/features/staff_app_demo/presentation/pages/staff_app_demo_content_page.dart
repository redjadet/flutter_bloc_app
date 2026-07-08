import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/utils/error_handling.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_content_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_content_state.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:video_player/video_player.dart';

part 'staff_app_demo_content_page_viewers.part.dart';

class StaffAppDemoContentPage extends StatelessWidget {
  const StaffAppDemoContentPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoContentCubit>().state;
    final l10n = context.l10n;
    final contentItems = List<StaffDemoContentItem>.of(
      state.items,
      growable: false,
    );

    return CommonPageLayout(
      title: l10n.staffDemoContentTitle,
      body: RefreshIndicator(
        onRefresh: context.cubit<StaffDemoContentCubit>().load,
        child: switch (state.status) {
          StaffDemoContentStatus.initial ||
          StaffDemoContentStatus.loading => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          StaffDemoContentStatus.error => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 240,
                child: Center(
                  child: Text(
                    state.errorMessage ?? l10n.staffDemoContentFailedToOpenItem,
                  ),
                ),
              ),
            ],
          ),
          StaffDemoContentStatus.ready =>
            contentItems.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 240,
                        child: Center(child: Text(l10n.staffDemoContentEmpty)),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: contentItems.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= contentItems.length) {
                        return const SizedBox.shrink();
                      }
                      final item = contentItems[index];
                      return _ContentTile(
                        key: ValueKey<String>(
                          'staff-content-${item.contentId}',
                        ),
                        item: item,
                      );
                    },
                  ),
        },
      ),
    );
  }
}
