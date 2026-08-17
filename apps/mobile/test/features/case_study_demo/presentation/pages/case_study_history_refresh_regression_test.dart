import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_detail_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_detail_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_page.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this._currentUser);

  final AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();
}

class _StubRemoteBackendAuth implements RemoteBackendAuthPort {
  @override
  bool get isConfigured => false;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  Future<void> signOut() async {}
}

class _StubRemoteRepository implements CaseStudyRemoteRepository {
  @override
  Future<String> uploadClip({
    required String caseId,
    required String questionId,
    required String localPath,
  }) async => '';

  @override
  Future<void> upsertRemoteDraft({
    required String caseId,
    required String doctorName,
    required CaseStudyCaseType caseType,
    required String notes,
    required Map<String, String> remoteObjectKeysByQuestion,
  }) async {}

  @override
  Future<void> finalizeRemoteSubmission({
    required String caseId,
    required String doctorName,
    required CaseStudyCaseType caseType,
    required String notes,
    required Map<String, String> remoteObjectKeysByQuestion,
    required DateTime submittedAtUtc,
  }) async {}

  @override
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() async =>
      <RemoteCaseStudySummary>[];

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required String caseId,
  }) async => null;

  @override
  Future<String> createSignedPlaybackUrl({
    required String objectKey,
    required Duration ttl,
  }) async => '';
}

class _StubRemoteDeleteRepository implements CaseStudyRemoteDeleteRepository {
  @override
  Future<void> deleteCaseStudyRemote({required String caseId}) async {}
}

class _NoopClipStore implements CaseStudyClipFileStore {
  @override
  Future<void> deleteCaseFolder(String caseId) async {}

  @override
  Future<void> deleteFileIfExists(String? path) async {}

  @override
  String finalClipFilePathFromStaging(String stagingPath) => stagingPath;

  @override
  Future<String> persistClip({
    required String sourcePath,
    required String caseId,
    required String questionId,
  }) async => sourcePath;

  @override
  Future<String> persistClipToStaging({
    required String sourcePath,
    required String caseId,
    required String questionId,
    required int commitToken,
  }) async => sourcePath;

  @override
  String promoteStagingToFinalSync({
    required String stagingPath,
    required String finalPath,
  }) => finalPath;

  @override
  Future<List<int>> readClipBytes(String path) async => const <int>[];
}

class _InMemoryLocalRepository implements CaseStudyLocalRepository {
  _InMemoryLocalRepository({required this.records, required this.byId});

  final List<CaseStudyRecord> records;
  final Map<String, CaseStudyRecord> byId;

  @override
  Future<void> ensureReady() async {}

  @override
  Future<CaseStudyDraft?> loadDraft(String userId) async => null;

  @override
  Future<void> saveDraft(String userId, CaseStudyDraft draft) async {}

  @override
  Future<void> clearDraft(String userId) async {}

  @override
  Future<List<CaseStudyRecord>> loadRecords(String userId) async => records;

  @override
  Future<void> saveRecords(
    String userId,
    List<CaseStudyRecord> records,
  ) async {}

  @override
  Future<CaseStudyRecord?> getRecord(String userId, String recordId) async =>
      byId[recordId];
}

Widget _buildHistoryPage() {
  return BlocProviderHelpers.withAsyncInit<CaseStudyHistoryCubit>(
    create: () => CaseStudyHistoryCubit(
      authRepository: getIt<AuthRepository>(),
      localRepository: getIt<CaseStudyLocalRepository>(),
      remoteRepository: getIt<CaseStudyRemoteRepository>(),
      remoteDeleteRepository: getIt<CaseStudyRemoteDeleteRepository>(),
      clipStore: getIt<CaseStudyClipFileStore>(),
      remoteBackendAuth: getIt<RemoteBackendAuthPort>(),
    ),
    init: (cubit) => cubit.load(),
    child: const CaseStudyHistoryPage(),
  );
}

Widget _buildHistoryDetailPage({required String recordId}) {
  return BlocProviderHelpers.withAsyncInit<CaseStudyHistoryDetailCubit>(
    create: () => CaseStudyHistoryDetailCubit(
      recordId: recordId,
      authRepository: getIt<AuthRepository>(),
      localRepository: getIt<CaseStudyLocalRepository>(),
      remoteRepository: getIt<CaseStudyRemoteRepository>(),
      remoteDeleteRepository: getIt<CaseStudyRemoteDeleteRepository>(),
      clipStore: getIt<CaseStudyClipFileStore>(),
      remoteBackendAuth: getIt<RemoteBackendAuthPort>(),
    ),
    init: (cubit) => cubit.load(),
    child: const CaseStudyHistoryDetailPage(),
  );
}

Future<void> _pumpLocalizedPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => buildAppMixScope(context, child: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _triggerPullToRefresh(
  WidgetTester tester,
  Finder scrollable,
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
      getIt.registerSingleton<RemoteBackendAuthPort>(_StubRemoteBackendAuth());
      getIt.registerSingleton<CaseStudyRemoteRepository>(
        _StubRemoteRepository(),
      );
      getIt.registerSingleton<CaseStudyLocalRepository>(
        _InMemoryLocalRepository(
          records: <CaseStudyRecord>[record],
          byId: <String, CaseStudyRecord>{'r1': record},
        ),
      );
      getIt.registerSingleton<CaseStudyRemoteDeleteRepository>(
        _StubRemoteDeleteRepository(),
      );
      getIt.registerSingleton<CaseStudyClipFileStore>(_NoopClipStore());
    });

    tearDown(() async {
      await getIt.reset(dispose: true);
    });

    testWidgets('history list pull-to-refresh throws no exceptions', (
      tester,
    ) async {
      await _pumpLocalizedPage(tester, _buildHistoryPage());

      expect(find.text('Dr. Test'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _triggerPullToRefresh(tester, find.byType(ListView));

      expect(tester.takeException(), isNull);
      expect(find.text('Dr. Test'), findsOneWidget);
    });

    testWidgets('history detail pull-to-refresh throws no exceptions', (
      tester,
    ) async {
      await _pumpLocalizedPage(tester, _buildHistoryDetailPage(recordId: 'r1'));

      expect(find.text('Dr. Test'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _triggerPullToRefresh(tester, find.byType(ListView));

      expect(tester.takeException(), isNull);
      expect(find.text('Dr. Test'), findsOneWidget);
    });
  });
}
