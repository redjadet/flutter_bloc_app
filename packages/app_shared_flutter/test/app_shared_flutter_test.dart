import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exports shared Flutter infrastructure APIs', () {
    expect(MediaPickErrorKeys.cancelled, 'cameraGalleryCancelled');
    expect(
      IntegrationLogMessages.offlineFirstRemoteConfigFetchFailed('fetch'),
      'OfflineFirstRemoteConfigRepository.fetch failed',
    );
    expect(platformEnvironment(), isA<Map<String, String>>());
  });

  test('MediaPickResult variants are constructible', () {
    expect(const MediaPickResult.success('/tmp/a.jpg'), isA<MediaPickResult>());
    expect(const MediaPickResult.cancelled(), isA<MediaPickResult>());
    expect(
      const MediaPickResult.failure(errorKey: MediaPickErrorKeys.generic),
      isA<MediaPickResult>(),
    );
  });
}
