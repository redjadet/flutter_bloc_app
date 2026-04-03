import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_hive_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_image_picker_video_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_mock_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/supabase_case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/supabase_case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';

void registerCaseStudyDemoServices() {
  registerLazySingletonIfAbsent<CaseStudyClipFileStore>(
    CaseStudyClipFileStore.new,
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
    SupabaseCaseStudyRemoteDeleteRepository.new,
  );

  registerLazySingletonIfAbsent<CaseStudyRemoteRepository>(
    SupabaseCaseStudyRemoteRepository.new,
  );
}
