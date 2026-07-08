import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/http/supabase/supabase_session_manager.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_clip_file_store.dart'
    show CaseStudyClipFileStoreImpl;
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_hive_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_image_picker_video_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_mock_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/supabase_case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/supabase_case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:storage/storage.dart';

void registerCaseStudyDemoServices() {
  registerLazySingletonIfAbsent<CaseStudyClipFileStore>(
    () => CaseStudyClipFileStoreImpl(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<CaseStudyLocalRepository>(
    () => CaseStudyHiveLocalRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<CaseStudyVideoRepository>(
    CaseStudyImagePickerVideoRepository.new,
  );
  registerLazySingletonIfAbsent<CaseStudyUploadRepository>(
    CaseStudyMockUploadRepository.new,
  );

  registerLazySingletonIfAbsent<CaseStudyRemoteDeleteRepository>(
    () => SupabaseCaseStudyRemoteDeleteRepository(
      sessionManager: getIt<SupabaseSessionManager>(),
    ),
  );

  registerLazySingletonIfAbsent<CaseStudyRemoteRepository>(
    () => SupabaseCaseStudyRemoteRepository(
      clipFileStore: getIt<CaseStudyClipFileStore>(),
    ),
  );
}
