import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/presentation/widgets/widgets.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            SizedBox(height: 8),
            CounterDisplay(),
          ],
        ),
      ),
      bottomNavigationBar: const CountdownBar(),
      floatingActionButton: const CounterActions(),
    );
  }
}
