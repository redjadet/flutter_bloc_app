import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/widgets/genui_demo_content.dart';

class GenUiDemoPage extends StatelessWidget {
  const GenUiDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.genuiDemoPageTitle,
      body: const GenUiDemoContent(),
    );
  }
}
