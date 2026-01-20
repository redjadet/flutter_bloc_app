import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/widgets/genui_demo_content.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class GenUiDemoPage extends StatelessWidget {
  const GenUiDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.genuiDemoPageTitle,
      body:
          TypeSafeBlocSelector<GenUiDemoCubit, GenUiDemoState, GenUiDemoState>(
            selector: (final state) => state,
            builder: (final context, final state) =>
                GenUiDemoContent(state: state),
          ),
    );
  }
}
