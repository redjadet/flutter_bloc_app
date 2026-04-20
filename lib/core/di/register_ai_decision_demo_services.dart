import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_api_client.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_repository.dart';

void registerAiDecisionDemoServices() {
  registerLazySingletonIfAbsent<AiDecisionApiClient>(
    () => AiDecisionApiClient(dio: getIt<Dio>()),
  );
  registerLazySingletonIfAbsent<AiDecisionRepository>(
    () => AiDecisionRepository(api: getIt<AiDecisionApiClient>()),
  );
}
