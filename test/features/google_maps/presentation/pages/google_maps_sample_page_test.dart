import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/pages/google_maps_sample_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../../test_utils/fake_google_maps_flutter_platform.dart';

class _MockMapSampleCubit extends MockCubit<MapSampleState>
    implements MapSampleCubit {}

class _MockNativePlatformService extends Mock
    implements NativePlatformService {}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleMapsFlutterPlatform.instance = FakeGoogleMapsFlutterPlatform();
    registerFallbackValue(MapSampleState.initial());
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('GoogleMapsSamplePage', () {
    late _MockMapSampleCubit cubit;
    late _MockNativePlatformService platformService;

    setUp(() {
      cubit = _MockMapSampleCubit();
      platformService = _MockNativePlatformService();
      when(() => cubit.close()).thenAnswer((_) async {});
      when(() => cubit.state).thenReturn(MapSampleState.initial());
      whenListen(
        cubit,
        Stream<MapSampleState>.empty(),
        initialState: MapSampleState.initial(),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    Future<void> pumpPage(
      WidgetTester tester, {
      required TargetPlatform platform,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<MapSampleCubit>.value(
            value: cubit,
            child: GoogleMapsSamplePage(
              platformService: platformService,
              platformOverride: platform,
            ),
          ),
        ),
      );
    }

    testWidgets('shows unsupported message on non-mobile platforms', (
      tester,
    ) async {
      when(
        () => platformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => true);
      when(() => cubit.state).thenReturn(MapSampleState.initial());

      await pumpPage(tester, platform: TargetPlatform.macOS);

      expect(
        find.text(l10n.googleMapsPageUnsupportedDescription),
        findsOneWidget,
      );
    });

    testWidgets('shows missing key message when API key is absent', (
      tester,
    ) async {
      when(
        () => platformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => false);
      when(() => cubit.state).thenReturn(MapSampleState.initial());

      await pumpPage(tester, platform: TargetPlatform.android);
      await tester.pumpAndSettle();

      expect(find.text(l10n.googleMapsPageMissingKeyTitle), findsOneWidget);
    });

    testWidgets('shows loading indicator when cubit is loading', (
      tester,
    ) async {
      when(
        () => platformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => true);
      when(
        () => cubit.state,
      ).thenReturn(MapSampleState.initial().copyWith(isLoading: true));

      await pumpPage(tester, platform: TargetPlatform.android);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when cubit has error', (tester) async {
      when(
        () => platformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => true);
      when(() => cubit.state).thenReturn(
        MapSampleState.initial().copyWith(
          isLoading: false,
          errorMessage: 'Error',
        ),
      );

      await pumpPage(tester, platform: TargetPlatform.android);
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
    });
  });
}
