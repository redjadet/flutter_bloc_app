import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/utils/case_study_local_video_exists.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
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

    final Uri? uri = Uri.tryParse(widget.videoPath);
    final bool isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (!isNetwork) {
      final String localPath = widget.videoPath;
      final bool onDisk = await caseStudyLocalVideoExists(localPath);
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

    final VideoPlayerController c = isNetwork
        ? VideoPlayerController.networkUrl(uri)
        : VideoPlayerController.file(File(widget.videoPath));
    try {
      await c.initialize();
      await c.setLooping(true);
      if (!mounted || token != _initToken) {
        await c.dispose();
        return;
      }
      setState(() {
        _controller = c;
      });
      await c.play();
    } on Object {
      await c.dispose();
      if (mounted) {
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
    final VideoPlayerController? c = _controller;
    _controller = null;
    if (c != null) {
      unawaited(c.dispose());
    }
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
