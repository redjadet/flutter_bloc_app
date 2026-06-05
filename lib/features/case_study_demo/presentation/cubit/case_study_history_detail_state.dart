import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';

enum CaseStudyHistoryDetailStatus {
  initial,
  loading,
  loaded,
  notFound,
  unavailable,
  error,
}

// check-ignore: freezed_preferred - demo detail state (kept lightweight)
class CaseStudyHistoryDetailState extends Equatable {
  const CaseStudyHistoryDetailState({
    this.status = CaseStudyHistoryDetailStatus.initial,
    this.record,
    this.usesExpiringCloudPlaybackUrls = false,
    this.errorMessage,
    this.transientError,
    this.isDeleting = false,
  });

  final CaseStudyHistoryDetailStatus status;
  final CaseStudyRecord? record;
  final bool usesExpiringCloudPlaybackUrls;
  final String? errorMessage;
  final Object? transientError;
  final bool isDeleting;

  bool get isLoading => status == CaseStudyHistoryDetailStatus.loading;

  CaseStudyHistoryDetailState copyWith({
    final CaseStudyHistoryDetailStatus? status,
    final CaseStudyRecord? record,
    final bool? usesExpiringCloudPlaybackUrls,
    final String? errorMessage,
    final bool clearErrorMessage = false,
    final Object? transientError,
    final bool clearTransientError = false,
    final bool clearRecord = false,
    final bool? isDeleting,
  }) => CaseStudyHistoryDetailState(
    status: status ?? this.status,
    record: clearRecord ? null : (record ?? this.record),
    usesExpiringCloudPlaybackUrls:
        usesExpiringCloudPlaybackUrls ?? this.usesExpiringCloudPlaybackUrls,
    errorMessage: clearErrorMessage
        ? null
        : (errorMessage ?? this.errorMessage),
    transientError: clearTransientError
        ? null
        : (transientError ?? this.transientError),
    isDeleting: isDeleting ?? this.isDeleting,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    record,
    usesExpiringCloudPlaybackUrls,
    errorMessage,
    transientError,
    isDeleting,
  ];
}
