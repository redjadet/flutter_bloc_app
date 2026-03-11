import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_page_body.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Simple page shown when the user is logged out (e.g. example flow).
class LoggedOutPage extends StatelessWidget {
  const LoggedOutPage({super.key});

  @override
  Widget build(final BuildContext context) => CommonPageLayout(
    title: context.l10n.exampleLoggedOutButton,
    useResponsiveBody: false,
    body: const LoggedOutPageBody(),
  );
}
