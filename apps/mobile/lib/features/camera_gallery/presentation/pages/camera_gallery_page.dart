import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/image_processing_filter.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_cubit.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

part 'camera_gallery_page.part.dart';

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
    return CommonPageLayout(
      title: context.l10n.cameraGalleryPageTitle,
      body: const _CameraGalleryPageBody(),
    );
  }
}

class _CameraGalleryPageBody extends StatelessWidget {
  const _CameraGalleryPageBody();

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: context.responsiveGapL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PreviewSection(theme: theme, colors: colors),
          SizedBox(height: context.responsiveGapL),
          const _ProcessingControls(),
          SizedBox(height: context.responsiveGapS),
          const _ActionButtons(),
          SizedBox(height: context.responsiveGapS),
          _ErrorSection(l10n: context.l10n, colors: colors),
        ],
      ),
    );
  }
}
