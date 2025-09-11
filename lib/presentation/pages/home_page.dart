import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/presentation/responsive.dart';
import 'package:flutter_bloc_app/presentation/ui_constants.dart';
import 'package:flutter_bloc_app/presentation/widgets/widgets.dart';
import 'package:flutter_bloc_app/theme_cubit.dart';

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
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                final bool isDark = mode == ThemeMode.dark;
                return IconButton(
                  tooltip: isDark ? 'Light mode' : 'Dark mode',
                  onPressed: () => context.read<ThemeCubit>().toggle(),
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).pushCountLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: UI.gapS),
                    const CounterDisplay(),
                    SizedBox(height: UI.gapM),
                    BlocBuilder<CounterCubit, CounterState>(
                      buildWhen: (p, c) => p.count != c.count,
                      builder: (context, state) {
                        if (state.count == 0) {
                          return Text(
                            AppLocalizations.of(context).startAutoHint,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CountdownBar(),
        floatingActionButton: const CounterActions(),
      ),
    );
  }
}
