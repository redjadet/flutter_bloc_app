import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_data_mode_badge.dart';

enum CaseStudyHistoryStatus { initial, loading, loaded, error }

// check-ignore: freezed_preferred - demo list state (kept lightweight)
class CaseStudyHistoryState extends Equatable {
  const CaseStudyHistoryState({
    this.status = CaseStudyHistoryStatus.initial,
    this.records = const <CaseStudyRecord>[],
    this.dataMode = CaseStudyDataMode.unknown,
    this.errorMessage,
    this.transientError,
    this.deletingRecordId,
  });

  final CaseStudyHistoryStatus status;
  final List<CaseStudyRecord> records;
  final CaseStudyDataMode dataMode;
  final String? errorMessage;
  final Object? transientError;
  final String? deletingRecordId;

  bool get isLoading => status == CaseStudyHistoryStatus.loading;

  CaseStudyHistoryState copyWith({
    final CaseStudyHistoryStatus? status,
    final List<CaseStudyRecord>? records,
    final CaseStudyDataMode? dataMode,
    final String? errorMessage,
    final bool clearErrorMessage = false,
    final Object? transientError,
    final bool clearTransientError = false,
    final String? deletingRecordId,
    final bool clearDeletingRecordId = false,
  }) => CaseStudyHistoryState(
    status: status ?? this.status,
    records: records ?? this.records,
    dataMode: dataMode ?? this.dataMode,
    errorMessage: clearErrorMessage
        ? null
        : (errorMessage ?? this.errorMessage),
    transientError: clearTransientError
        ? null
        : (transientError ?? this.transientError),
    deletingRecordId: clearDeletingRecordId
        ? null
        : (deletingRecordId ?? this.deletingRecordId),
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    records,
    dataMode,
    errorMessage,
    transientError,
    deletingRecordId,
  ];
}
