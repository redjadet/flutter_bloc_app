import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
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
  @override
  bool get isConfigured => false;

  @override
  AuthUser? get currentUser => null;

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
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() async =>
      <RemoteCaseStudySummary>[];

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required final String caseId,
  }) async => null;

  @override
  Future<String> createSignedPlaybackUrl({
    required final String objectKey,
    required final Duration ttl,
  }) async => '';
}

class _InMemoryLocalRepository implements CaseStudyLocalRepository {
  _InMemoryLocalRepository({required this.records, required this.byId});

  final List<CaseStudyRecord> records;
  final Map<String, CaseStudyRecord> byId;

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
      records;

  @override
  Future<void> saveRecords(
    final String userId,
    final List<CaseStudyRecord> records,
  ) async {}

  @override
  Future<CaseStudyRecord?> getRecord(
    final String userId,
    final String recordId,
  ) async => byId[recordId];
}

Future<void> _pumpLocalizedPage(
  final WidgetTester tester,
  final Widget page,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (final context) => buildAppMixScope(context, child: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _triggerPullToRefresh(
  final WidgetTester tester,
  final Finder scrollable,
) async {
  await tester.drag(scrollable, const Offset(0, 300));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
}

void main() {
  group('case study history refresh regression', () {
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
      getIt.registerSingleton<CaseStudyLocalRepository>(
        _InMemoryLocalRepository(
          records: <CaseStudyRecord>[record],
          byId: <String, CaseStudyRecord>{'r1': record},
        ),
      );
    });

    tearDown(() async {
      await getIt.reset(dispose: true);
    });

    testWidgets('history list pull-to-refresh throws no exceptions', (
      final tester,
    ) async {
      await _pumpLocalizedPage(tester, const CaseStudyHistoryPage());

      expect(find.text('Dr. Test'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _triggerPullToRefresh(tester, find.byType(ListView));

      expect(tester.takeException(), isNull);
      expect(find.text('Dr. Test'), findsOneWidget);
    });

    testWidgets('history detail pull-to-refresh throws no exceptions', (
      final tester,
    ) async {
      await _pumpLocalizedPage(
        tester,
        const CaseStudyHistoryDetailPage(recordId: 'r1'),
      );

      expect(find.text('Dr. Test'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _triggerPullToRefresh(tester, find.byType(ListView));

      expect(tester.takeException(), isNull);
      expect(find.text('Dr. Test'), findsOneWidget);
    });
  });
}
