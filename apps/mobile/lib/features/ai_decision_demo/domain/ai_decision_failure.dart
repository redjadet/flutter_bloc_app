import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_decision_failure.freezed.dart';

@freezed
sealed class AiDecisionFailure with _$AiDecisionFailure implements Exception {
  const AiDecisionFailure._();

  const factory AiDecisionFailure.load({
    final String? message,
    final Object? cause,
  }) = AiDecisionLoadFailure;

  const factory AiDecisionFailure.unknown({
    final String? message,
    final Object? cause,
  }) = AiDecisionUnknownFailure;

  String get displayMessage => when(
    load: (final message, _) => message ?? 'Failed to load AI decision data.',
    unknown: (final message, _) => message ?? 'Something went wrong.',
  );
}
