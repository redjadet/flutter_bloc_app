import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_page_body.dart';
import 'package:material_ui/material_ui.dart';

/// Simple page shown when the user is logged out (e.g. example flow).
class LoggedOutPage extends StatelessWidget {
  const LoggedOutPage({super.key});

  @override
  Widget build(BuildContext context) => CommonPageLayout(
    title: context.l10n.exampleLoggedOutButton,
    useResponsiveBody: false,
    body: const LoggedOutPageBody(),
  );
}
