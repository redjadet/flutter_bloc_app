import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/playlearn/data/asset_vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/data/tts_audio_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';

/// Registers playlearn (kids vocabulary) services.
void registerPlaylearnServices() {
  registerLazySingletonIfAbsent<VocabularyRepository>(
    AssetVocabularyRepository.new,
  );
  registerLazySingletonIfAbsent<AudioPlaybackService>(TtsAudioService.new);
}
