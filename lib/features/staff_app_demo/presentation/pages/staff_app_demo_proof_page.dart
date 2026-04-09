import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoProofPage extends StatelessWidget {
  const StaffAppDemoProofPage({super.key});

  @override
  Widget build(final BuildContext context) => const CommonPageLayout(
    title: 'Proof',
    body: Center(
      child: Text('Phase 3: photos + signature capture goes here.'),
    ),
  );
}
