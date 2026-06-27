import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/widgets/staff_demo_proof_signature_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/layout_overflow_expectations.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStaffDemoEventProofRepository extends Mock
    implements StaffDemoEventProofRepository {}

class _MockStaffDemoProofFileStore extends Mock
    implements StaffDemoProofFileStore {}

class _MockStaffDemoProofPhotoPicker extends Mock
    implements StaffDemoProofPhotoPicker {}

Widget _wrapStaffSignatureSection(StaffDemoProofCubit cubit) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<StaffDemoProofCubit>.value(
      value: cubit,
      child: Builder(
        builder: (final BuildContext context) => buildAppMixScope(
          context,
          child: const Scaffold(body: StaffDemoProofSignatureSection()),
        ),
      ),
    ),
  );
}

void main() {
  late StaffDemoProofCubit cubit;
  late _MockAuthRepository authRepository;
  late _MockStaffDemoEventProofRepository repository;
  late _MockStaffDemoProofFileStore fileStore;

  setUp(() {
    authRepository = _MockAuthRepository();
    repository = _MockStaffDemoEventProofRepository();
    fileStore = _MockStaffDemoProofFileStore();
    when(() => authRepository.currentUser).thenReturn(
      const AuthUser(id: 'u1', email: 'user@example.com', isAnonymous: false),
    );
    when(() => fileStore.fileExists(any())).thenAnswer((_) async => false);
    when(() => fileStore.deleteFileAtPath(any())).thenAnswer((_) async {});
    cubit = StaffDemoProofCubit(
      authRepository: authRepository,
      repository: repository,
      fileStore: fileStore,
      photoPicker: _MockStaffDemoProofPhotoPicker(),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  Future<void> pumpAtWidth(WidgetTester tester, double width) async {
    final previousPhysicalSize = tester.view.physicalSize;
    final previousDevicePixelRatio = tester.view.devicePixelRatio;
    addTearDown(() {
      tester.view.physicalSize = previousPhysicalSize;
      tester.view.devicePixelRatio = previousDevicePixelRatio;
    });
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(_wrapStaffSignatureSection(cubit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets(
    'StaffDemoProofSignatureSection action row does not overflow at 320dp',
    (WidgetTester tester) async {
      final capture = startLayoutOverflowCapture();
      addTearDown(capture.dispose);
      await pumpAtWidth(tester, 320);
      expectNoRenderOverflows(capture.errors);
      expect(tester.takeException(), isNull);
      expect(find.byType(OverflowBar), findsOneWidget);
    },
  );

  testWidgets(
    'StaffDemoProofSignatureSection action row does not overflow at 360dp',
    (WidgetTester tester) async {
      final capture = startLayoutOverflowCapture();
      addTearDown(capture.dispose);
      await pumpAtWidth(tester, 360);
      expectNoRenderOverflows(capture.errors);
      expect(tester.takeException(), isNull);
      expect(find.byType(OverflowBar), findsOneWidget);
    },
  );
}
