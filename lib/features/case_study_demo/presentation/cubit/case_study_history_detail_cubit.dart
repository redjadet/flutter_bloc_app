import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/remote_backend_auth_port.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_detail_state.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_detail_signing.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';
import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';

export 'case_study_history_detail_state.dart';

part 'case_study_history_detail_cubit_actions.part.dart';

class CaseStudyHistoryDetailCubit extends _CaseStudyHistoryDetailCubitBase
    with _CaseStudyHistoryDetailCubitActions {
  CaseStudyHistoryDetailCubit({
    required final String recordId,
    required final AuthRepository authRepository,
    required final CaseStudyLocalRepository localRepository,
    required final CaseStudyRemoteRepository remoteRepository,
    required final CaseStudyRemoteDeleteRepository remoteDeleteRepository,
    required final CaseStudyClipFileStore clipStore,
    required final RemoteBackendAuthPort remoteBackendAuth,
  }) : super(
         recordId: recordId,
         authRepository: authRepository,
         localRepository: localRepository,
         remoteRepository: remoteRepository,
         remoteDeleteRepository: remoteDeleteRepository,
         clipStore: clipStore,
         remoteBackendAuth: remoteBackendAuth,
       );
}

abstract class _CaseStudyHistoryDetailCubitBase
    extends Cubit<CaseStudyHistoryDetailState> {
  _CaseStudyHistoryDetailCubitBase({
    required final String recordId,
    required final AuthRepository authRepository,
    required final CaseStudyLocalRepository localRepository,
    required final CaseStudyRemoteRepository remoteRepository,
    required final CaseStudyRemoteDeleteRepository remoteDeleteRepository,
    required final CaseStudyClipFileStore clipStore,
    required final RemoteBackendAuthPort remoteBackendAuth,
  }) : _recordId = recordId,
       _authRepository = authRepository,
       _local = localRepository,
       _remote = remoteRepository,
       _remoteDelete = remoteDeleteRepository,
       _clipStore = clipStore,
       _remoteAuth = remoteBackendAuth,
       super(const CaseStudyHistoryDetailState());

  final String _recordId;
  final AuthRepository _authRepository;
  final CaseStudyLocalRepository _local;
  final CaseStudyRemoteRepository _remote;
  final CaseStudyRemoteDeleteRepository _remoteDelete;
  final CaseStudyClipFileStore _clipStore;
  final RemoteBackendAuthPort _remoteAuth;
  final RequestIdGuard _loadGuard = RequestIdGuard();
}
