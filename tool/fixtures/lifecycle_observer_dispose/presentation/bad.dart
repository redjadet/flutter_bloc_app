import 'package:flutter/widgets.dart';

class BadObserverPage extends StatefulWidget {
  const BadObserverPage({super.key});

  @override
  State<BadObserverPage> createState() => _BadObserverPageState();
}

class _BadObserverPageState extends State<BadObserverPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(final BuildContext context) => const SizedBox.shrink();
}
