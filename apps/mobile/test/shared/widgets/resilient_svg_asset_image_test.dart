import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  tearDown(ResilientSvgAssetImage.debugClearCache);

  group('ResilientSvgAssetImage', () {
    Widget createWidget({
      required String assetPath,
      BoxFit fit = BoxFit.contain,
      Widget Function()? fallbackBuilder,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ResilientSvgAssetImage(
            assetPath: assetPath,
            fit: fit,
            fallbackBuilder: fallbackBuilder ?? () => const SizedBox.shrink(),
          ),
        ),
      );
    }

    testWidgets('displays fallback while loading', (tester) async {
      await tester.pumpWidget(
        createWidget(
          assetPath: 'assets/test.svg',
          fallbackBuilder: () => const Text('Loading...'),
        ),
      );

      // Initially shows fallback while FutureBuilder is waiting
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('displays fallback when asset load fails', (tester) async {
      await tester.pumpWidget(
        createWidget(
          assetPath: 'assets/nonexistent.svg',
          fallbackBuilder: () => const Text('Error'),
        ),
      );

      await tester.pumpAndSettle();

      // Should show fallback when asset doesn't exist
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('creates widget with required parameters', (tester) async {
      const widget = ResilientSvgAssetImage(
        assetPath: 'assets/test.svg',
        fit: BoxFit.cover,
        fallbackBuilder: SizedBox.shrink,
      );

      expect(widget.assetPath, 'assets/test.svg');
      expect(widget.fit, BoxFit.cover);
      expect(widget.fallbackBuilder, isNotNull);
    });

    testWidgets('handles different BoxFit values', (tester) async {
      await tester.pumpWidget(
        createWidget(
          assetPath: 'assets/test.svg',
          fit: BoxFit.fill,
          fallbackBuilder: () => const SizedBox.shrink(),
        ),
      );

      // Widget should render without errors
      expect(find.byType(ResilientSvgAssetImage), findsOneWidget);
    });

    testWidgets('calls fallbackBuilder when provided', (tester) async {
      bool fallbackCalled = false;
      await tester.pumpWidget(
        createWidget(
          assetPath: 'assets/nonexistent.svg',
          fallbackBuilder: () {
            fallbackCalled = true;
            return const Text('Fallback');
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(fallbackCalled, isTrue);
      expect(find.text('Fallback'), findsOneWidget);
    });

    testWidgets('parent rebuild does not restart asset load while waiting', (
      tester,
    ) async {
      ResilientSvgAssetImage.debugResetLoadStarts();

      await tester.pumpWidget(
        const _RebuildHost(
          child: ResilientSvgAssetImage(
            assetPath: 'assets/nonexistent_async.svg',
            fit: BoxFit.contain,
            fallbackBuilder: _loadingFallback,
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(ResilientSvgAssetImage.debugLoadStarts, 1);

      final hostState =
          tester.state(find.byType(_RebuildHost)) as _RebuildHostState;
      hostState.rebuild();
      await tester.pump();

      expect(find.text('Loading...'), findsOneWidget);
      expect(
        ResilientSvgAssetImage.debugLoadStarts,
        1,
        reason:
            'Future must live outside build so rebuilds do not restart load',
      );

      await tester.pumpAndSettle();
    });
  });
}

Widget _loadingFallback() => const Text('Loading...');

class _RebuildHost extends StatefulWidget {
  const _RebuildHost({required this.child});

  final Widget child;

  @override
  State<_RebuildHost> createState() => _RebuildHostState();
}

class _RebuildHostState extends State<_RebuildHost> {
  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(home: Scaffold(body: widget.child));
}
