import 'dart:async';

import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS implementation of [AudioPlaybackService] using flutter_tts.
class TtsAudioService implements AudioPlaybackService {
  TtsAudioService() {
    unawaited(_tts.setLanguage('en-US'));
  }

  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> speak(final String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
