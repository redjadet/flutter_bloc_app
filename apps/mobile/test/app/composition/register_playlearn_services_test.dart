import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_playlearn_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/playlearn/data/asset_vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/data/tts_audio_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _flutterTtsChannel = MethodChannel('flutter_tts');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_flutterTtsChannel, (
          final MethodCall call,
        ) async {
          return null;
        });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_flutterTtsChannel, null);
  });

  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test('registerPlaylearnServices registers vocabulary and audio services', () {
    registerPlaylearnServices();

    expect(getIt<VocabularyRepository>(), isA<AssetVocabularyRepository>());
    expect(getIt<AudioPlaybackService>(), isA<TtsAudioService>());
  });
}
