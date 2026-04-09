import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoContentPage extends StatelessWidget {
  const StaffAppDemoContentPage({super.key});

  @override
  Widget build(final BuildContext context) => const CommonPageLayout(
    title: 'Content',
    body: Center(
      child: Text('Phase 3: PDF/video library goes here.'),
    ),
  );
}
