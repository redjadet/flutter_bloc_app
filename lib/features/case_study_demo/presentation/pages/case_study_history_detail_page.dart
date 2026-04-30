// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart'
    show
        CaseStudyRemoteRepository,
        RemoteCaseStudyDetail,
        kCaseStudySignedPlaybackUrlTtl;
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_question_prompt.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_detail_signing.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_video_tile.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';
import 'package:intl/intl.dart';

part 'case_study_history_detail_page_impl.part.dart';
