import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/router/route_scoped_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockGoRouterState extends Mock implements GoRouterState {}

class _UnusedInitCubit extends Cubit<int> {
  _UnusedInitCubit() : super(0);
}

void main() {
  test('RouteScopedPage.noTransition keys page with state.pageKey', () {
    final state = _MockGoRouterState();
    const pageKey = ValueKey<String>('demo-page');
    when(() => state.pageKey).thenReturn(pageKey);

    final page = RouteScopedPage.noTransition(
      state: state,
      child: const SizedBox(key: Key('child')),
    );

    expect(page, isA<NoTransitionPage<void>>());
    expect(page.key, pageKey);
  });

  testWidgets('RouteScopedPage.route pageBuilder uses state.pageKey', (
    tester,
  ) async {
    final state = _MockGoRouterState();
    const pageKey = ValueKey<String>('route-page');
    when(() => state.pageKey).thenReturn(pageKey);

    final route = RouteScopedPage.route(
      path: '/demo',
      name: 'demo',
      builder: (_, _) => const SizedBox.shrink(),
    );

    late Page<void> page;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            page = route.pageBuilder!(context, state);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(page.key, pageKey);
    expect(page, isA<NoTransitionPage<void>>());
  });

  testWidgets('RouteScopedPage.routeWithCubit allows omitted init', (
    tester,
  ) async {
    final state = _MockGoRouterState();
    when(() => state.pageKey).thenReturn(const ValueKey<String>('cubit-page'));

    final route = RouteScopedPage.routeWithCubit<_UnusedInitCubit>(
      path: '/cubit',
      name: 'cubit',
      create: (_, _) => _UnusedInitCubit(),
      child: const SizedBox(key: Key('cubit-child')),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final page =
                route.pageBuilder!(context, state) as NoTransitionPage<void>;
            return page.child;
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('cubit-child')), findsOneWidget);
  });
}
