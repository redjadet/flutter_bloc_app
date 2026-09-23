import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_detail_state.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_state.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Equatable 3.0 regression: props equality still drives Cubit rebuilds.
void main() {
  tearDown(() {
    EquatableConfig.stringify = true;
  });

  group('CaseStudyDraft / Record equality (Equatable 3.0)', () {
    test('drafts with identical props are equal', () {
      final CaseStudyDraft a = CaseStudyDraft.fresh(caseId: 'c1')
          .copyWith(doctorName: 'Ada', caseType: CaseStudyCaseType.ortho);
      final CaseStudyDraft b = CaseStudyDraft.fresh(caseId: 'c1')
          .copyWith(doctorName: 'Ada', caseType: CaseStudyCaseType.ortho);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('drafts differ when a prop changes', () {
      final CaseStudyDraft a = CaseStudyDraft.fresh(caseId: 'c1');
      final CaseStudyDraft b = a.copyWith(doctorName: 'Grace');
      expect(a, isNot(equals(b)));
    });

    test('records with identical props are equal', () {
      final DateTime at = DateTime.utc(2026, 1, 2, 3, 4, 5);
      final CaseStudyRecord a = CaseStudyRecord(
        id: 'r1',
        submittedAt: at,
        doctorName: 'Ada',
        caseType: CaseStudyCaseType.ortho,
        notes: 'n',
        answers: const <String, String>{'q1': '/a.mp4'},
      );
      final CaseStudyRecord b = CaseStudyRecord(
        id: 'r1',
        submittedAt: at,
        doctorName: 'Ada',
        caseType: CaseStudyCaseType.ortho,
        notes: 'n',
        answers: const <String, String>{'q1': '/a.mp4'},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('CaseStudy session/history states (Equatable 3.0)', () {
    test('session states with identical props are equal', () {
      final CaseStudyDraft draft = CaseStudyDraft.fresh(caseId: 'c1');
      final CaseStudySessionState a = CaseStudySessionState(
        hydration: CaseStudyHydrationStatus.ready,
        draft: draft,
      );
      final CaseStudySessionState b = CaseStudySessionState(
        hydration: CaseStudyHydrationStatus.ready,
        draft: draft,
      );
      expect(a, equals(b));
    });

    test('history states with identical records are equal', () {
      final CaseStudyHistoryState a = CaseStudyHistoryState(
        status: CaseStudyHistoryStatus.loaded,
        records: const <CaseStudyRecord>[],
      );
      final CaseStudyHistoryState b = CaseStudyHistoryState(
        status: CaseStudyHistoryStatus.loaded,
        records: const <CaseStudyRecord>[],
      );
      expect(a, equals(b));
    });

    test('detail states with identical props are equal', () {
      final CaseStudyHistoryDetailState a = CaseStudyHistoryDetailState(
        status: CaseStudyHistoryDetailStatus.loaded,
      );
      final CaseStudyHistoryDetailState b = CaseStudyHistoryDetailState(
        status: CaseStudyHistoryDetailStatus.loaded,
      );
      expect(a, equals(b));
    });

    test('stringify false still uses Object toString (3.0 behavior)', () {
      EquatableConfig.stringify = false;
      final CaseStudyDraft draft = CaseStudyDraft.fresh(caseId: 'c1');
      expect(draft.toString(), equals("Instance of 'CaseStudyDraft'"));
    });
  });
}
