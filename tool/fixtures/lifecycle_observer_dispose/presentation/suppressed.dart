import 'package:flutter/widgets.dart';

class SuppressedObserverPage extends StatefulWidget {
  const SuppressedObserverPage({super.key});

  @override
  State<SuppressedObserverPage> createState() => _SuppressedObserverPageState();
}

class _SuppressedObserverPageState extends State<SuppressedObserverPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // check-ignore: lifecycle observer dispose fixture
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(final BuildContext context) => const SizedBox.shrink();
}
