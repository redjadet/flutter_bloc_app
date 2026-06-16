import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_error_keys.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_result.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:image_picker/image_picker.dart';

/// [CaseStudyVideoRepository] using [ImagePicker.pickVideo].
class CaseStudyImagePickerVideoRepository implements CaseStudyVideoRepository {
  CaseStudyImagePickerVideoRepository({
    final ImagePicker? picker,
    final bool Function()? isAndroid,
  }) : _picker = picker ?? ImagePicker(),
       _isAndroid = isAndroid ?? _defaultIsAndroid;

  final ImagePicker _picker;
  final bool Function() _isAndroid;

  static bool _defaultIsAndroid() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<MediaPickResult> pickVideoFromCamera() async =>
      _pickVideo(source: ImageSource.camera, isCamera: true);

  @override
  Future<MediaPickResult> pickVideoFromGallery() async =>
      _pickVideo(source: ImageSource.gallery, isCamera: false);

  Future<MediaPickResult> _pickVideo({
    required final ImageSource source,
    required final bool isCamera,
  }) async {
    try {
      final XFile? file = await _picker.pickVideo(source: source);
      if (file == null) return const MediaPickResult.cancelled();

      final String path = file.path;
      if (path.isEmpty) {
        return const MediaPickResult.failure(
          errorKey: MediaPickErrorKeys.generic,
        );
      }

      return MediaPickResult.success(path);
    } on PlatformException catch (error) {
      return _mapPlatformException(error);
    } on Object catch (error) {
      if (isCamera) {
        return _mapCameraException(error);
      }
      return MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.generic,
        message: error.toString(),
      );
    }
  }

  MediaPickResult _mapPlatformException(final PlatformException error) {
    final String code = error.code.toLowerCase();
    final String message = (error.message ?? '').toLowerCase();

    final bool isPermissionDenied =
        code.contains('permission') ||
        code.contains('access_denied') ||
        code.contains('restricted') ||
        code == 'photo_access_denied' ||
        code == 'camera_access_denied' ||
        message.contains('permission denied') ||
        message.contains('access denied') ||
        message.contains('not allowed') ||
        message.contains('restricted');
    if (isPermissionDenied) {
      return const MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.permissionDenied,
      );
    }

    if (_isCameraUnavailableCodeOrMessage(code, error.message)) {
      return const MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.cameraUnavailable,
      );
    }

    return MediaPickResult.failure(
      errorKey: MediaPickErrorKeys.generic,
      message: error.message,
    );
  }

  static bool _isCameraUnavailableCodeOrMessage(
    final String code,
    final String? message,
  ) {
    final String lowerCode = code.toLowerCase();
    if (lowerCode == 'no_available_camera' ||
        lowerCode == 'camera_not_available' ||
        lowerCode == 'camera_unavailable' ||
        lowerCode.contains('camera_unavailable') ||
        lowerCode.contains('camera_not_available')) {
      return true;
    }

    final String lower = message?.toLowerCase() ?? '';
    return lower.contains('no cameras available') ||
        lower.contains('no camera available') ||
        lower.contains('camera not available') ||
        lower.contains('camera unavailable') ||
        lower.contains('camera is not available') ||
        lower.contains('no camera found');
  }

  MediaPickResult _mapCameraException(final Object error) {
    final String message = error.toString();
    if (_isCameraUnavailableCodeOrMessage('', message)) {
      return const MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.cameraUnavailable,
      );
    }

    return MediaPickResult.failure(
      errorKey: MediaPickErrorKeys.generic,
      message: message,
    );
  }

  @override
  Future<MediaPickResult?> retrieveLostVideo() async {
    if (!_isAndroid()) return null;

    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;

      final String? path = _extractLostPath(response);
      if (path != null &&
          (response.type == RetrieveType.video || _isProbablyVideoPath(path))) {
        return MediaPickResult.success(path);
      }

      if (response.exception case final PlatformException exception?) {
        return _mapPlatformException(exception);
      }

      return null;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'CaseStudyImagePickerVideoRepository.retrieveLostVideo',
        error,
        stackTrace,
      );
      return null;
    }
  }

  /// Best-effort: treat common video extensions; otherwise rely on [RetrieveType].
  static bool _isProbablyVideoPath(final String path) {
    final String lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }

  static String? _extractLostPath(final LostDataResponse response) {
    final String directPath = response.file?.path ?? '';
    if (directPath.isNotEmpty) {
      return directPath;
    }

    final List<XFile>? files = response.files;
    if (files == null || files.isEmpty) {
      return null;
    }

    for (final XFile file in files) {
      final String path = file.path;
      if (path.isNotEmpty) {
        return path;
      }
    }

    return null;
  }
}
