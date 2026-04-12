import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_forms_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/sites/staff_demo_sites_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockFormsRepository extends Mock implements StaffDemoFormsRepository {}

class _MockSiteRepository extends Mock implements StaffDemoSiteRepository {}

void main() {
  testWidgets('manager report preserves notes when submission fails', (
    tester,
  ) async {
    final authRepository = _MockAuthRepository();
    final formsRepository = _MockFormsRepository();
    final siteRepository = _MockSiteRepository();

    when(() => authRepository.currentUser).thenReturn(
      const AuthUser(id: 'u1', email: 'user@example.com', isAnonymous: false),
    );
    when(
      () => authRepository.authStateChanges,
    ).thenAnswer((_) => const Stream<AuthUser?>.empty());
    when(
      () => formsRepository.submitManagerReport(
        userId: any(named: 'userId'),
        siteId: any(named: 'siteId'),
        notes: any(named: 'notes'),
      ),
    ).thenThrow(Exception('submit failed'));
    when(() => siteRepository.listSites()).thenAnswer((_) async => const []);
    when(
      () => siteRepository.loadSite(siteId: any(named: 'siteId')),
    ).thenAnswer((_) async => null);

    final formsCubit = StaffDemoFormsCubit(
      authRepository: authRepository,
      repository: formsRepository,
    );
    addTearDown(formsCubit.close);
    final sitesCubit = StaffDemoSitesCubit(repository: siteRepository);
    addTearDown(sitesCubit.close);
    sitesCubit.emit(
      StaffDemoSitesState(
        status: StaffDemoSitesStatus.ready,
        sites: const <StaffDemoSite>[
          StaffDemoSite(
            siteId: 'site1',
            name: 'Warehouse',
            centerLat: 0,
            centerLng: 0,
            radiusMeters: 100,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<StaffDemoFormsCubit>.value(value: formsCubit),
          BlocProvider<StaffDemoSitesCubit>.value(value: sitesCubit),
        ],
        child: const MaterialApp(home: StaffAppDemoFormsPage()),
      ),
    );
    await tester.pump();

    const noteText = 'Keep this note';
    final submitReportButton = find.widgetWithText(
      FilledButton,
      'Submit report',
    );
    await tester.scrollUntilVisible(submitReportButton, 200);
    final notesField = find.byType(TextField);
    expect(notesField, findsOneWidget);
    await tester.ensureVisible(notesField);
    await tester.pump();
    await tester.tap(notesField);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), noteText);
    await tester.tap(submitReportButton);
    await tester.pumpAndSettle();

    final notesTextField = tester.widget<TextField>(notesField);
    expect(notesTextField.controller?.text, noteText);
  });
}
