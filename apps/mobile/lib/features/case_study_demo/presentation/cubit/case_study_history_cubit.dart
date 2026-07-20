import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_state.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_data_mode_badge.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';

export 'case_study_history_state.dart';

class CaseStudyHistoryCubit extends Cubit<CaseStudyHistoryState> {
  CaseStudyHistoryCubit({
    required this._authRepository,
    required final CaseStudyLocalRepository localRepository,
    required final CaseStudyRemoteRepository remoteRepository,
    required final CaseStudyRemoteDeleteRepository remoteDeleteRepository,
    required this._clipStore,
    required final RemoteBackendAuthPort remoteBackendAuth,
  }) : _local = localRepository,
       _remote = remoteRepository,
       _remoteDelete = remoteDeleteRepository,
       _remoteAuth = remoteBackendAuth,
       super(const CaseStudyHistoryState());

  final AuthRepository _authRepository;
  final CaseStudyLocalRepository _local;
  final CaseStudyRemoteRepository _remote;
  final CaseStudyRemoteDeleteRepository _remoteDelete;
  final CaseStudyClipFileStore _clipStore;
  final RemoteBackendAuthPort _remoteAuth;
  final RequestIdGuard _loadGuard = RequestIdGuard();

  void clearTransientError() {
    if (isClosed || state.transientError == null) return;
    emit(state.copyWith(clearTransientError: true));
  }

  Future<void> load() async {
    if (isClosed) return;
    final int requestId = _loadGuard.next();
    emit(
      state.copyWith(
        status: CaseStudyHistoryStatus.loading,
        clearErrorMessage: true,
        clearTransientError: true,
      ),
    );

    await CubitExceptionHandler.executeAsync<List<CaseStudyRecord>>(
      operation: _fetchRecords,
      isAlive: () => !isClosed,
      logContext: 'CaseStudyHistoryCubit.load',
      onSuccess: (final records) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        emit(
          CaseStudyHistoryState(
            status: CaseStudyHistoryStatus.loaded,
            records: records,
            dataMode: CaseStudyDataModeBadge.fromRemoteBackendAuth(_remoteAuth),
          ),
        );
      },
      onError: (final message) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        emit(
          state.copyWith(
            status: CaseStudyHistoryStatus.error,
            errorMessage: message,
          ),
        );
      },
    );
  }

  Future<void> refresh() => load();

  Future<void> deleteRecord({required final String recordId}) async {
    if (isClosed || state.deletingRecordId != null || recordId.isEmpty) return;

    final String? userId = _authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    emit(
      state.copyWith(
        deletingRecordId: recordId,
        clearTransientError: true,
      ),
    );

    final bool isRemote =
        _remoteAuth.isConfigured && _remoteAuth.currentUser != null;

    try {
      if (isRemote) {
        await _remoteDelete.deleteCaseStudyRemote(caseId: recordId);
      } else {
        await _local.ensureReady();
        final List<CaseStudyRecord> records = await _local.loadRecords(userId);
        final List<CaseStudyRecord> next = records
            .where((final r) => r.id != recordId)
            .toList();
        await _local.saveRecords(userId, next);
        await _clipStore.deleteCaseFolder(recordId);
      }

      if (isClosed) return;
      emit(state.copyWith(clearDeletingRecordId: true));
      await load();
    } on Object catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          clearDeletingRecordId: true,
          transientError: error,
        ),
      );
    }
  }

  Future<List<CaseStudyRecord>> _fetchRecords() async {
    final String? userId = _authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return const <CaseStudyRecord>[];
    }

    if (_remoteAuth.isConfigured && _remoteAuth.currentUser != null) {
      final List<RemoteCaseStudySummary> summaries = await _remote
          .listSubmittedCases();
      return summaries
          .map(
            (final s) => CaseStudyRecord(
              id: s.caseId,
              submittedAt: s.submittedAtUtc,
              doctorName: s.doctorName,
              caseType: s.caseType,
              notes: s.notes,
              answers: const <String, String>{},
            ),
          )
          .toList();
    }

    await _local.ensureReady();
    return _local.loadRecords(userId);
  }
}
