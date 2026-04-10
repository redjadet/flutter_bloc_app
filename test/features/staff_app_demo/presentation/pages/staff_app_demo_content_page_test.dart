import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/content/staff_demo_content_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_content_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _FakeStaffDemoContentRepository implements StaffDemoContentRepository {
  @override
  Future<Uri> getDownloadUrl({required final String storagePath}) async {
    return Uri.parse('https://example.com/video.mp4');
  }

  @override
  Future<List<StaffDemoContentItem>> listPublished() async {
    return const <StaffDemoContentItem>[
      StaffDemoContentItem(
        contentId: 'video-1',
        title: 'Demo Video',
        type: StaffDemoContentType.video,
        storagePath: 'staff-app-demo/content/demo-video.mp4',
        isPublished: true,
      ),
    ];
  }
}

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  _FakeVideoPlayerPlatform({required this.forceInitError});

  final bool forceInitError;
  final Map<int, StreamController<VideoEvent>> _streams =
      <int, StreamController<VideoEvent>>{};
  int _nextPlayerId = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final int playerId = _nextPlayerId++;
    final controller = StreamController<VideoEvent>();
    _streams[playerId] = controller;
    if (forceInitError) {
      controller.addError(
        PlatformException(
          code: 'VideoError',
          message: 'Video player had error XYZ',
        ),
      );
    } else {
      controller.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          size: Size(100, 100),
          duration: Duration(seconds: 1),
        ),
      );
    }
    return playerId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(final int playerId) {
    return _streams[playerId]!.stream;
  }

  @override
  Future<void> dispose(final int playerId) async {
    await _streams.remove(playerId)?.close();
  }

  @override
  Future<void> play(final int playerId) async {}

  @override
  Future<void> pause(final int playerId) async {}

  @override
  Future<void> setLooping(final int playerId, final bool looping) async {}

  @override
  Future<void> setVolume(final int playerId, final double volume) async {}

  @override
  Future<void> seekTo(final int playerId, final Duration position) async {}

  @override
  Future<void> setPlaybackSpeed(final int playerId, final double speed) async {}

  @override
  Widget buildViewWithOptions(final VideoViewOptions options) {
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets('video content shows fallback when initialization fails', (
    tester,
  ) async {
    final previousPlatform = VideoPlayerPlatform.instance;
    VideoPlayerPlatform.instance = _FakeVideoPlayerPlatform(
      forceInitError: true,
    );
    addTearDown(() => VideoPlayerPlatform.instance = previousPlatform);

    final cubit = StaffDemoContentCubit(
      repository: _FakeStaffDemoContentRepository(),
    );
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const StaffAppDemoContentPage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Demo Video'));
    await tester.pumpAndSettle();

    expect(find.text('Could not load this video.'), findsOneWidget);
  });
}
