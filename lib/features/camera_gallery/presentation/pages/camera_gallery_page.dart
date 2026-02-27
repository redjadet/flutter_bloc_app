import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_cubit.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Demo page: take a photo or pick from gallery and show preview.
class CameraGalleryPage extends StatefulWidget {
  const CameraGalleryPage({super.key});

  @override
  State<CameraGalleryPage> createState() => _CameraGalleryPageState();
}

class _CameraGalleryPageState extends State<CameraGalleryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.cubit<CameraGalleryCubit>().initialize());
    });
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return CommonPageLayout(
      title: l10n.cameraGalleryPageTitle,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: context.responsiveGapL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PreviewSection(theme: theme, colors: colors),
            SizedBox(height: context.responsiveGapL),
            _ActionButtons(l10n: l10n),
            SizedBox(height: context.responsiveGapS),
            _ErrorSection(l10n: l10n, colors: colors),
          ],
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.theme,
    required this.colors,
  });

  final ThemeData theme;
  final ColorScheme colors;

  Widget _buildEmptyPreview(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: context.responsiveIconSize * 3,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: context.responsiveGapS),
          Text(
            context.l10n.cameraGalleryNoImage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return TypeSafeBlocBuilder<CameraGalleryCubit, CameraGalleryState>(
      buildWhen: (final prev, final next) =>
          prev.imagePath != next.imagePath || prev.status != next.status,
      builder: (final context, final state) {
        final bool loading = state.isLoading;
        final String? path = state.imagePath;
        return Semantics(
          container: true,
          child: Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(context.responsiveCardRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: loading
                ? Center(
                    child: SizedBox(
                      width: context.responsiveIconSize * 2,
                      height: context.responsiveIconSize * 2,
                      child: CircularProgressIndicator(
                        color: colors.primary,
                      ),
                    ),
                  )
                : path != null && path.isNotEmpty
                ? Image.file(
                    File(path),
                    fit: BoxFit.contain,
                    errorBuilder:
                        (
                          final _,
                          final error,
                          final stackTrace,
                        ) {
                          AppLogger.error(
                            'CameraGalleryPage.imagePreviewLoad',
                            error,
                            stackTrace,
                          );
                          return _buildEmptyPreview(context);
                        },
                  )
                : _buildEmptyPreview(context),
          ),
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    return TypeSafeBlocBuilder<CameraGalleryCubit, CameraGalleryState>(
      buildWhen: (final prev, final next) => prev.status != next.status,
      builder: (final context, final state) {
        final bool loading = state.isLoading;
        return Column(
          children: [
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: loading
                  ? null
                  : () => context.cubit<CameraGalleryCubit>().pickFromCamera(),
              child: IconLabelRow(
                icon: Icons.camera_alt_outlined,
                label: l10n.cameraGalleryTakePhoto,
              ),
            ),
            SizedBox(height: context.responsiveGapS),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: loading
                  ? null
                  : () => context.cubit<CameraGalleryCubit>().pickFromGallery(),
              child: IconLabelRow(
                icon: Icons.photo_library_outlined,
                label: l10n.cameraGalleryPickFromGallery,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({
    required this.l10n,
    required this.colors,
  });

  final AppLocalizations l10n;
  final ColorScheme colors;

  @override
  Widget build(final BuildContext context) {
    return TypeSafeBlocSelector<
      CameraGalleryCubit,
      CameraGalleryState,
      String?
    >(
      selector: (final s) => s.errorKey,
      builder: (final context, final errorKey) {
        if (errorKey == null || errorKey.isEmpty) {
          return const SizedBox.shrink();
        }
        final String message = _errorKeyToMessage(l10n, errorKey);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: context.responsiveGapM),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.error,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  static String _errorKeyToMessage(
    final AppLocalizations l10n,
    final String key,
  ) {
    switch (key) {
      case CameraGalleryErrorKeys.permissionDenied:
        return l10n.cameraGalleryPermissionDenied;
      case CameraGalleryErrorKeys.cameraUnavailable:
        return l10n.cameraGalleryCameraUnavailable;
      case CameraGalleryErrorKeys.cancelled:
        return l10n.cameraGalleryCancelled;
      case CameraGalleryErrorKeys.generic:
      default:
        return l10n.cameraGalleryGenericError;
    }
  }
}
