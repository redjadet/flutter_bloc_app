import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_decision_failure.freezed.dart';

@freezed
sealed class AiDecisionFailure with _$AiDecisionFailure implements Exception {
  const new _();

  const factory load({String? message, Object? cause}) = AiDecisionLoadFailure;

  const factory unknown({String? message, Object? cause}) =
      AiDecisionUnknownFailure;

  String get displayMessage => when(
    load: (message, _) => message ?? 'Failed to load AI decision data.',
    unknown: (message, _) => message ?? 'Something went wrong.',
  );
}
