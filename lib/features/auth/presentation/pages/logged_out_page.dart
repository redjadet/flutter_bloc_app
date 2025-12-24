import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_page_body.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class LoggedOutPage extends StatelessWidget {
  const LoggedOutPage({super.key});

  @override
  Widget build(final BuildContext context) => const CommonPageLayout(
    title: 'Logged Out',
    body: LoggedOutPageBody(),
  );
}
