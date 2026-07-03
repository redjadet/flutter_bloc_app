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
import 'package:utilities/utilities.dart';

export 'case_study_history_detail_state.dart';

part 'case_study_history_detail_cubit_actions.part.dart';
part 'case_study_history_detail_cubit_fetch.part.dart';

class CaseStudyHistoryDetailCubit extends _CaseStudyHistoryDetailCubitBase
    with
        _CaseStudyHistoryDetailCubitFetch,
        _CaseStudyHistoryDetailCubitActions {
  CaseStudyHistoryDetailCubit({
    required super.recordId,
    required super.authRepository,
    required super.localRepository,
    required super.remoteRepository,
    required super.remoteDeleteRepository,
    required super.clipStore,
    required super.remoteBackendAuth,
  });
}

abstract class _CaseStudyHistoryDetailCubitBase
    extends Cubit<CaseStudyHistoryDetailState> {
  _CaseStudyHistoryDetailCubitBase({
    required this.recordId,
    required this.authRepository,
    required CaseStudyLocalRepository localRepository,
    required CaseStudyRemoteRepository remoteRepository,
    required CaseStudyRemoteDeleteRepository remoteDeleteRepository,
    required this.clipStore,
    required RemoteBackendAuthPort remoteBackendAuth,
  }) : _local = localRepository,
       _remote = remoteRepository,
       _remoteDelete = remoteDeleteRepository,
       _remoteAuth = remoteBackendAuth,
       super(const CaseStudyHistoryDetailState());

  final String recordId;
  final AuthRepository authRepository;
  final CaseStudyClipFileStore clipStore;
  final CaseStudyLocalRepository _local;
  final CaseStudyRemoteRepository _remote;
  final CaseStudyRemoteDeleteRepository _remoteDelete;
  final RemoteBackendAuthPort _remoteAuth;
  final RequestIdGuard _loadGuard = RequestIdGuard();
}
