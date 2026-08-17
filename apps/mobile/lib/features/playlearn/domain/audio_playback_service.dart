/// Abstraction over speech/audio playback (e.g. TTS) (pure Dart, Flutter-free).
abstract class AudioPlaybackService {
  /// Speaks the given text (e.g. English word).
  Future<void> speak(String text);

  /// Stops current playback if any.
  Future<void> stop();
}
