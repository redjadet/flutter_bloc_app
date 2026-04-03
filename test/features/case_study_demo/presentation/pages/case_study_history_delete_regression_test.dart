import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_detail_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_page.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this._currentUser);

  final AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();
}

class _StubSupabaseAuthRepository implements SupabaseAuthRepository {
  _StubSupabaseAuthRepository({this.configured = false, this.user});

  final bool configured;
  final AuthUser? user;

  @override
  bool get isConfigured => configured;

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) async {}
}

class _StubRemoteRepository implements CaseStudyRemoteRepository {
  _StubRemoteRepository({
    this.summaries = const <RemoteCaseStudySummary>[],
    this.detail,
  });

  final List<RemoteCaseStudySummary> summaries;
  final RemoteCaseStudyDetail? detail;

  @override
  Future<String> uploadClip({
    required final String caseId,
    required final String questionId,
    required final String localPath,
  }) async => '';

  @override
  Future<void> upsertRemoteDraft({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
  }) async {}

  @override
  Future<void> finalizeRemoteSubmission({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
    required final DateTime submittedAtUtc,
  }) async {}

  @override
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() async => summaries;

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required final String caseId,
  }) async => detail;

  @override
  Future<String> createSignedPlaybackUrl({
    required final String objectKey,
    required final Duration ttl,
  }) async => '';
}

class _StubRemoteDeleteRepository implements CaseStudyRemoteDeleteRepository {
  int callCount = 0;
  String? lastCaseId;

  @override
  Future<void> deleteCaseStudyRemote({required final String caseId}) async {
    callCount += 1;
    lastCaseId = caseId;
  }
}

class _NoopClipStore extends CaseStudyClipFileStore {
  int deleteFolderCount = 0;
  String? lastCaseId;

  @override
  Future<void> deleteCaseFolder(final String caseId) async {
    deleteFolderCount += 1;
    lastCaseId = caseId;
  }
}

class _MutableLocalRepository implements CaseStudyLocalRepository {
  _MutableLocalRepository({required final List<CaseStudyRecord> initialRecords})
    : _records = List<CaseStudyRecord>.from(initialRecords);

  List<CaseStudyRecord> _records;

  @override
  Future<void> ensureReady() async {}

  @override
  Future<CaseStudyDraft?> loadDraft(final String userId) async => null;

  @override
  Future<void> saveDraft(
    final String userId,
    final CaseStudyDraft draft,
  ) async {}

  @override
  Future<void> clearDraft(final String userId) async {}

  @override
  Future<List<CaseStudyRecord>> loadRecords(final String userId) async =>
      List<CaseStudyRecord>.from(_records);

  @override
  Future<void> saveRecords(
    final String userId,
    final List<CaseStudyRecord> records,
  ) async {
    _records = List<CaseStudyRecord>.from(records);
  }

  @override
  Future<CaseStudyRecord?> getRecord(
    final String userId,
    final String recordId,
  ) async {
    for (final CaseStudyRecord r in _records) {
      if (r.id == recordId) return r;
    }
    return null;
  }
}

Widget _buildApp({required final Widget home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    builder: (final context, final child) =>
        buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
    home: home,
  );
}

void main() {
  group('case study history delete regression', () {
    setUp(() async {
      await getIt.reset(dispose: true);

      const user = AuthUser(id: 'user-1', isAnonymous: false);
      final String qid = CaseStudyQuestions.orderedIds.first;
      final CaseStudyRecord record = CaseStudyRecord(
        id: 'r1',
        submittedAt: DateTime.utc(2026, 4, 1, 12),
        doctorName: 'Dr. Test',
        caseType: CaseStudyCaseType.implant,
        notes: 'notes',
        answers: <String, String>{qid: '/tmp/video.mp4'},
      );

      getIt.registerSingleton<AuthRepository>(_StubAuthRepository(user));
      getIt.registerSingleton<SupabaseAuthRepository>(
        _StubSupabaseAuthRepository(),
      );
      getIt.registerSingleton<CaseStudyRemoteRepository>(
        _StubRemoteRepository(),
      );
      getIt.registerSingleton<CaseStudyRemoteDeleteRepository>(
        _StubRemoteDeleteRepository(),
      );
      getIt.registerSingleton<CaseStudyLocalRepository>(
        _MutableLocalRepository(initialRecords: <CaseStudyRecord>[record]),
      );
      getIt.registerSingleton<CaseStudyClipFileStore>(_NoopClipStore());
    });

    tearDown(() async {
      await getIt.reset(dispose: true);
    });

    testWidgets('deletes from history list (local mode) after confirmation', (
      final tester,
    ) async {
      await tester.pumpWidget(_buildApp(home: const CaseStudyHistoryPage()));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Test'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Delete case?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Dr. Test'), findsNothing);
    });

    testWidgets('deletes from detail page and pops back to root', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          builder: (final context, final child) => buildAppMixScope(
            context,
            child: child ?? const SizedBox.shrink(),
          ),
          initialRoute: '/detail',
          routes: <String, WidgetBuilder>{
            '/': (final context) =>
                const Scaffold(body: Text('root placeholder')),
            '/detail': (final context) =>
                const CaseStudyHistoryDetailPage(recordId: 'r1'),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Test'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete case?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('root placeholder'), findsOneWidget);
    });

    testWidgets(
      'calls remote delete from history list when Supabase is active',
      (final tester) async {
        await getIt.reset(dispose: true);

        const user = AuthUser(id: 'user-1', isAnonymous: false);
        final List<RemoteCaseStudySummary> summaries = <RemoteCaseStudySummary>[
          RemoteCaseStudySummary(
            caseId: 'r1',
            submittedAtUtc: DateTime.utc(2026, 4, 1, 12),
            doctorName: 'Dr. Test',
            caseType: CaseStudyCaseType.implant,
            notes: 'notes',
          ),
        ];

        final remoteDelete = _StubRemoteDeleteRepository();

        getIt.registerSingleton<AuthRepository>(_StubAuthRepository(user));
        getIt.registerSingleton<SupabaseAuthRepository>(
          _StubSupabaseAuthRepository(configured: true, user: user),
        );
        getIt.registerSingleton<CaseStudyRemoteRepository>(
          _StubRemoteRepository(summaries: summaries),
        );
        getIt.registerSingleton<CaseStudyRemoteDeleteRepository>(remoteDelete);
        getIt.registerSingleton<CaseStudyLocalRepository>(
          _MutableLocalRepository(initialRecords: const <CaseStudyRecord>[]),
        );
        getIt.registerSingleton<CaseStudyClipFileStore>(_NoopClipStore());

        await tester.pumpWidget(_buildApp(home: const CaseStudyHistoryPage()));
        await tester.pumpAndSettle();

        expect(find.text('Dr. Test'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(remoteDelete.callCount, 1);
        expect(remoteDelete.lastCaseId, 'r1');
      },
    );

    testWidgets('calls remote delete from detail when Supabase is active', (
      final tester,
    ) async {
      await getIt.reset(dispose: true);

      const user = AuthUser(id: 'user-1', isAnonymous: false);
      final remoteDelete = _StubRemoteDeleteRepository();

      final RemoteCaseStudyDetail detail = RemoteCaseStudyDetail(
        caseId: 'r1',
        submittedAtUtc: DateTime.utc(2026, 4, 1, 12),
        doctorName: 'Dr. Test',
        caseType: CaseStudyCaseType.implant,
        notes: 'notes',
        remoteObjectKeysByQuestion: const <String, String>{},
      );

      getIt.registerSingleton<AuthRepository>(_StubAuthRepository(user));
      getIt.registerSingleton<SupabaseAuthRepository>(
        _StubSupabaseAuthRepository(configured: true, user: user),
      );
      getIt.registerSingleton<CaseStudyRemoteRepository>(
        _StubRemoteRepository(detail: detail),
      );
      getIt.registerSingleton<CaseStudyRemoteDeleteRepository>(remoteDelete);
      getIt.registerSingleton<CaseStudyLocalRepository>(
        _MutableLocalRepository(initialRecords: const <CaseStudyRecord>[]),
      );
      getIt.registerSingleton<CaseStudyClipFileStore>(_NoopClipStore());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          builder: (final context, final child) => buildAppMixScope(
            context,
            child: child ?? const SizedBox.shrink(),
          ),
          initialRoute: '/detail',
          routes: <String, WidgetBuilder>{
            '/': (final context) =>
                const Scaffold(body: Text('root placeholder')),
            '/detail': (final context) =>
                const CaseStudyHistoryDetailPage(recordId: 'r1'),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Test'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(remoteDelete.callCount, 1);
      expect(remoteDelete.lastCaseId, 'r1');
      expect(find.text('root placeholder'), findsOneWidget);
    });
  });
}
