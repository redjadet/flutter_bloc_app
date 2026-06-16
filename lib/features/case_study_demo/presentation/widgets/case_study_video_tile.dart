import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/utils/case_study_local_video_exists.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/utils/case_study_video_blob_lifecycle.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/utils/case_study_video_controller_factory.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:video_player/video_player.dart';

/// Inline video preview with lifecycle-safe controller ownership.
class CaseStudyVideoTile extends StatefulWidget {
  const CaseStudyVideoTile({
    required this.videoPath,
    required this.l10n,
    super.key,
  });

  final String videoPath;
  final AppLocalizations l10n;

  @override
  State<CaseStudyVideoTile> createState() => _CaseStudyVideoTileState();
}

class _CaseStudyVideoTileState extends State<CaseStudyVideoTile>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _fileMissing = false;
  bool _initFailed = false;
  int _initToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_init());
  }

  Future<void> _init() async {
    final int token = ++_initToken;
    final String videoPath = widget.videoPath;

    final Uri? uri = Uri.tryParse(videoPath);
    final bool skipExistsCheck =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'blob');

    if (!skipExistsCheck) {
      final bool onDisk = await caseStudyLocalVideoExists(videoPath);
      if (!onDisk) {
        if (mounted) {
          setState(() {
            _fileMissing = true;
            _initFailed = false;
          });
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        _fileMissing = false;
        _initFailed = false;
      });
    }

    try {
      final VideoPlayerController c = await createCaseStudyVideoController(
        videoPath,
      );
      try {
        await c.initialize();
        await c.setLooping(true);
        if (!mounted || token != _initToken) {
          await c.dispose();
          releaseCaseStudyVideoBlobForPath(videoPath);
          return;
        }
        setState(() {
          _controller = c;
        });
        await c.play();
      } on Object catch (error, stackTrace) {
        await c.dispose();
        releaseCaseStudyVideoBlobForPath(videoPath);
        AppLogger.error('CaseStudyVideoTile init failed', error, stackTrace);
        if (mounted && token == _initToken) {
          setState(() {
            _initFailed = true;
            _controller = null;
          });
        }
      }
    } on Object catch (error, stackTrace) {
      releaseCaseStudyVideoBlobForPath(videoPath);
      AppLogger.error(
        'CaseStudyVideoTile controller create failed',
        error,
        stackTrace,
      );
      if (mounted && token == _initToken) {
        setState(() {
          _initFailed = true;
          _controller = null;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant final CaseStudyVideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _disposeController();
      _fileMissing = false;
      _initFailed = false;
      unawaited(_init());
    }
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    final VideoPlayerController? c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(c.pause());
    }
  }

  void _disposeController() {
    _initToken++;
    final String pathToRelease = widget.videoPath;
    final VideoPlayerController? c = _controller;
    _controller = null;
    if (c != null) {
      unawaited(c.dispose());
    }
    releaseCaseStudyVideoBlobForPath(pathToRelease);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (_fileMissing || _initFailed) {
      return Text(
        _fileMissing
            ? widget.l10n.caseStudyVideoMissing
            : widget.l10n.caseStudyErrorGeneric,
      );
    }
    final VideoPlayerController? c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
      child: VideoPlayer(c),
    );
  }
}
