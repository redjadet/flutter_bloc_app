import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/presentation/widgets/widgets.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterCubit, CounterState>(
      listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        final String? message = state.errorMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          context.read<CounterCubit>().clearError();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: BlocBuilder<CounterCubit, CounterState>(
          buildWhen: (p, c) => p.status != c.status,
          builder: (context, state) {
            if (state.status == CounterStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('You have pushed the button this many times:'),
                  SizedBox(height: 8),
                  CounterDisplay(),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const CountdownBar(),
        floatingActionButton: const CounterActions(),
      ),
    );
  }
}
