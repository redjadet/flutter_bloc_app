import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';
import 'package:flutter_bloc_app/features/notes_demo/presentation/cubit/notes_cubit.dart';
import 'package:flutter_bloc_app/features/notes_demo/presentation/cubit/notes_state.dart';
import 'package:flutter_bloc_app/features/notes_demo/presentation/pages/notes_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotesCubit extends MockCubit<NotesState> implements NotesCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockNotesCubit cubit;
  final DateTime stamp = DateTime.utc(2024, 1, 1);

  setUp(() {
    cubit = _MockNotesCubit();
    when(() => cubit.state).thenReturn(const NotesState(isLoading: false));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.close()).thenAnswer((_) async {});
    when(() => cubit.start()).thenAnswer((_) async {});
    when(
      () => cubit.saveNote(
        title: any(named: 'title'),
        body: any(named: 'body'),
        existing: any(named: 'existing'),
      ),
    ).thenAnswer((_) async {});
    when(() => cubit.deleteNote(any())).thenAnswer((_) async {});
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
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: const NotesDemoPage(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows progress while loading', (tester) async {
    when(() => cubit.state).thenReturn(const NotesState());
    await pumpPage(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state with create button', (tester) async {
    await pumpPage(tester);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('lists notes when loaded', (tester) async {
    when(() => cubit.state).thenReturn(
      NotesState(
        isLoading: false,
        notes: <Note>[
          Note(
            id: '1',
            title: 'Alpha',
            body: 'Body',
            createdAt: stamp,
            updatedAt: stamp,
          ),
        ],
      ),
    );
    await pumpPage(tester);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('delete icon calls deleteNote', (tester) async {
    when(() => cubit.state).thenReturn(
      NotesState(
        isLoading: false,
        notes: <Note>[
          Note(
            id: '1',
            title: 'Alpha',
            body: '',
            createdAt: stamp,
            updatedAt: stamp,
          ),
        ],
      ),
    );
    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    verify(() => cubit.deleteNote('1')).called(1);
  });

  testWidgets('FAB opens editor dialog', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
