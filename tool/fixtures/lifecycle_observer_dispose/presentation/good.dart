import 'package:flutter/widgets.dart';

class GoodObserverPage extends StatefulWidget {
  const GoodObserverPage({super.key});

  @override
  State<GoodObserverPage> createState() => _GoodObserverPageState();
}

class _GoodObserverPageState extends State<GoodObserverPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => const SizedBox.shrink();
}
