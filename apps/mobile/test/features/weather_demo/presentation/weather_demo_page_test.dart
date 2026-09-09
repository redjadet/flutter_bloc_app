import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_failure.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_cubit.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_state.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/pages/weather_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockWeatherCubit cubit;

  setUp(() {
    cubit = _MockWeatherCubit();
    when(() => cubit.state).thenReturn(const WeatherIdle());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.close()).thenAnswer((_) async {});
    when(() => cubit.search(any())).thenAnswer((_) async {});
    when(() => cubit.retry()).thenAnswer((_) async {});
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<WeatherCubit>.value(
            value: cubit,
            child: const WeatherDemoPage(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders search field on idle', (tester) async {
    await pumpPage(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('shows progress while loading', (tester) async {
    when(() => cubit.state).thenReturn(const WeatherLoading(query: 'Berlin'));
    await pumpPage(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows snapshot when success', (tester) async {
    when(() => cubit.state).thenReturn(
      WeatherSuccess(
        WeatherSnapshot(
          placeName: 'Berlin',
          latitude: 52.5,
          longitude: 13.4,
          temperatureC: 18,
          weatherCode: 0,
          weatherDescription: 'Clear sky',
          windSpeedKmh: 12,
          observedAt: DateTime.utc(2024, 1, 1, 12),
          hourly: <WeatherHourlyPoint>[
            WeatherHourlyPoint(
              time: DateTime.utc(2024, 1, 1, 13),
              temperatureC: 19,
            ),
          ],
        ),
      ),
    );
    await pumpPage(tester);
    expect(find.textContaining('Berlin'), findsWidgets);
    expect(find.textContaining('Clear sky'), findsOneWidget);
  });

  testWidgets('shows failure and retry', (tester) async {
    when(() => cubit.state)
        .thenReturn(const WeatherFailureState(WeatherNetworkFailure()));
    await pumpPage(tester);
    expect(find.textContaining('Network error'), findsOneWidget);
    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();
    verify(() => cubit.retry()).called(1);
  });

  testWidgets('search button triggers cubit.search', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    verify(() => cubit.search('Paris')).called(1);
  });
}
