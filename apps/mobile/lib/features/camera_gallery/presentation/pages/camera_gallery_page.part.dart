// Strict inference needs explicit errorBuilder parameter types.
// ignore_for_file: avoid_types_on_closure_parameters

part of 'camera_gallery_page.dart';

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
    return TypeSafeBlocSelector<
      CameraGalleryCubit,
      CameraGalleryState,
      _PreviewViewData
    >(
      selector: (final state) => _PreviewViewData(
        isLoading: state.isLoading,
        imagePath: state.imagePath,
      ),
      builder: (final context, final preview) {
        return _PreviewContainer(
          colors: colors,
          child: switch (preview) {
            _PreviewViewData(isLoading: true) => _PreviewLoadingState(
              colors: colors,
            ),
            _PreviewViewData(imagePath: final path?) when path.isNotEmpty =>
              _PreviewImage(
                path: path,
                emptyPreviewBuilder: () => _buildEmptyPreview(context),
              ),
            _ => _buildEmptyPreview(context),
          },
        );
      },
    );
  }
}

class _PreviewContainer extends StatelessWidget {
  const _PreviewContainer({
    required this.colors,
    required this.child,
  });

  final ColorScheme colors;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
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
        child: child,
      ),
    );
  }
}

class _PreviewLoadingState extends StatelessWidget {
  const _PreviewLoadingState({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: SizedBox(
        width: context.responsiveIconSize * 2,
        height: context.responsiveIconSize * 2,
        child: CircularProgressIndicator(color: colors.primary),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({
    required this.path,
    required this.emptyPreviewBuilder,
  });

  final String path;
  final Widget Function() emptyPreviewBuilder;

  @override
  Widget build(final BuildContext context) {
    return imageFromPath(
      path: path,
      fit: BoxFit.contain,
      errorBuilder:
          (
            final BuildContext _,
            final Object error,
            final StackTrace? stackTrace,
          ) {
            AppLogger.error(
              'CameraGalleryPage.imagePreviewLoad',
              error,
              stackTrace,
            );
            return emptyPreviewBuilder();
          },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return TypeSafeBlocSelector<CameraGalleryCubit, CameraGalleryState, bool>(
      selector: (final state) => state.isLoading,
      builder: (final context, final loading) {
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

class _PreviewViewData {
  const _PreviewViewData({
    required this.isLoading,
    required this.imagePath,
  });

  final bool isLoading;
  final String? imagePath;
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
