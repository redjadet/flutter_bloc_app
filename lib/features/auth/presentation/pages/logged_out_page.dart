import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_page_body.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';

class LoggedOutPage extends StatelessWidget {
  const LoggedOutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const RootAwareBackButton(homeTooltip: 'Home'),
      title: const Text('Logged Out'),
    ),
    body: const LoggedOutPageBody(),
  );
}
