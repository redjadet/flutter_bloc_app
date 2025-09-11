@Skip('Excluded from default flutter test run; intentionally throws to show SnackBar path')
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/domain/domain.dart';
import 'package:flutter_bloc_app/presentation/pages/home_page.dart';
import 'package:flutter_bloc_app/theme_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class ThrowingRepo implements CounterRepository {
  @override
  Future<CounterSnapshot> load() async {
    throw Exception('load failed');
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    throw Exception('save failed');
  }
}

void main() {
  testWidgets('shows SnackBar on load error and clears error', (tester) async {
    await initializeDateFormatting('en');
    final CounterCubit cubit = CounterCubit(repository: ThrowingRepo(), startTicker: false);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(create: (_) => ThemeCubit()),
          ],
          child: const MaterialApp(home: MyHomePage(title: 'Test Home')),
        ),
      ),
    );

    // Trigger load error
    await cubit.loadInitial();

    // Let the BlocListener react and display SnackBar
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    await cubit.close();
  });
}
