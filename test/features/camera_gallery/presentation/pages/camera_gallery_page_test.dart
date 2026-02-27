import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_repository.dart';
import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_result.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/cubit/camera_gallery_cubit.dart';
import 'package:flutter_bloc_app/features/camera_gallery/presentation/pages/camera_gallery_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRepository implements CameraGalleryRepository {
  _StubRepository({this.cameraResult, this.galleryResult});

  final CameraGalleryResult? cameraResult;
  final CameraGalleryResult? galleryResult;

  @override
  Future<CameraGalleryResult> pickFromCamera() async =>
      cameraResult ?? const CameraGalleryResult.cancelled();

  @override
  Future<CameraGalleryResult> pickFromGallery() async =>
      galleryResult ?? const CameraGalleryResult.cancelled();

  @override
  Future<CameraGalleryResult?> retrieveLostImage() async => null;
}

void main() {
  group('CameraGalleryPage', () {
    testWidgets('renders placeholder and both action buttons', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider<CameraGalleryCubit>(
            create: (_) => CameraGalleryCubit(repository: _StubRepository()),
            child: const CameraGalleryPage(),
          ),
        ),
      );

      expect(find.text('No image selected'), findsOneWidget);
      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Pick from gallery'), findsOneWidget);
    });

    testWidgets('renders preview when state has image path', (
      final tester,
    ) async {
      final cubit = CameraGalleryCubit(
        repository: _StubRepository(
          galleryResult: const CameraGalleryResult.success('/tmp/test.jpg'),
        ),
      );
      await cubit.pickFromGallery();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider<CameraGalleryCubit>(
            create: (_) => cubit,
            child: const CameraGalleryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows camera unavailable message when camera is missing', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider<CameraGalleryCubit>(
            create: (_) => CameraGalleryCubit(
              repository: _StubRepository(
                cameraResult: const CameraGalleryResult.failure(
                  errorKey: CameraGalleryErrorKeys.cameraUnavailable,
                ),
              ),
            ),
            child: const CameraGalleryPage(),
          ),
        ),
      );

      await tester.tap(find.text('Take photo'));
      await tester.pump();

      expect(
        find.text(
          'Camera is not available. Use a real device or pick from gallery.',
        ),
        findsOneWidget,
      );
    });
  });
}
