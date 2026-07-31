import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/example_page_body.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Example page exposes Online Therapy Demo entry', (tester) async {
    var tapped = false;

    await tester.binding.setSurfaceSize(const Size(400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            final theme = Theme.of(context);
            return SingleChildScrollView(
              child: ExamplePageBody(
                l10n: l10n,
                theme: theme,
                colors: theme.colorScheme,
                onBackPressed: () {},
                onLoadPlatformInfo: null,
                onOpenWebsocket: () {},
                onOpenRealtimeMarket: () {},
                onOpenCertificatePinningDemo: () {},
                onOpenChatList: () {},
                onOpenSearch: () {},
                onOpenTodoList: () {},
                onOpenProfile: () {},
                onOpenRegister: () {},
                onOpenLoggedOut: () {},
                onOpenLibraryDemo: () {},
                onOpenIgamingDemo: () {},
                onOpenStaffAppDemo: () {},
                onOpenScapes: () {},
                onOpenWalletconnectAuth: () {},
                onOpenCameraGallery: () {},
                onOpenCaseStudyDemo: () {},
                onOpenIapDemo: () {},
                onOpenAiDecisionDemo: () {},
                onOpenOnlineTherapyDemo: () {
                  tapped = true;
                },
                onOpenProductionReadiness: () {},
                onOpenEventBusDemo: () {},
                onOpenNativePlatformShowcase: () {},
                onRunIsolates: null,
                isRunningIsolates: false,
                isolateError: null,
                fibonacciInput: null,
                fibonacciResult: null,
                parallelValues: null,
                parallelDuration: null,
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    final Finder button = find.byKey(
      const ValueKey('example-online-therapy-demo-button'),
    );
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.tap(button);
    expect(tapped, isTrue);
  });
}
