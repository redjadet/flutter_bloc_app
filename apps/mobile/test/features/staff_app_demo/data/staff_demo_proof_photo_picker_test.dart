import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_pick_memory.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class _MockImagePicker extends Mock implements ImagePicker {}

class _FakeXFile extends Fake implements XFile {
  _FakeXFile(
    this.path, {
    this.bytes = const <int>[1, 2, 3],
    this.name = 'photo.jpg',
  });

  @override
  final String path;

  @override
  final String name;

  final List<int> bytes;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List.fromList(bytes);
}

void main() {
  late _MockImagePicker picker;
  late ImagePickerStaffDemoProofPhotoPicker photoPicker;

  setUp(() {
    picker = _MockImagePicker();
    photoPicker = ImagePickerStaffDemoProofPhotoPicker(picker: picker);
  });

  test('returns success when image path is non-empty', () async {
    when(
      () => picker.pickImage(source: ImageSource.gallery),
    ).thenAnswer((_) async => _FakeXFile('/tmp/photo.jpg'));

    final MediaPickResult result = await photoPicker.pickFromGallery();

    expect(result, const MediaPickResult.success('/tmp/photo.jpg'));
  });

  test(
    'returns staged pick path when web picker returns empty path with bytes',
    () async {
      const List<int> bytes = <int>[10, 20, 30];
      when(
        () => picker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => _FakeXFile('', bytes: bytes, name: 'shot.png'));

      final MediaPickResult result = await photoPicker.pickFromGallery();

      result.maybeWhen(
        success: (final String imagePath) {
          expect(
            imagePath,
            startsWith(StaffDemoProofPickMemory.pickPathPrefix),
          );
          expect(StaffDemoProofPickMemory.instance.take(imagePath), bytes);
        },
        orElse: () => fail('expected success result'),
      );
    },
  );

  test('returns failure when web pick bytes exceed maxWebPickBytes', () async {
    final List<int> oversized = List<int>.filled(
      ImagePickerStaffDemoProofPhotoPicker.maxWebPickBytes + 1,
      1,
    );
    when(
      () => picker.pickImage(source: ImageSource.gallery),
    ).thenAnswer((_) async => _FakeXFile('', bytes: oversized));

    final MediaPickResult result = await photoPicker.pickFromGallery();

    expect(
      result,
      const MediaPickResult.failure(errorKey: MediaPickErrorKeys.fileTooLarge),
    );
  });

  test('returns failure when empty path and zero bytes', () async {
    when(
      () => picker.pickImage(source: ImageSource.gallery),
    ).thenAnswer((_) async => _FakeXFile('', bytes: <int>[]));

    final MediaPickResult result = await photoPicker.pickFromGallery();

    expect(
      result,
      const MediaPickResult.failure(errorKey: MediaPickErrorKeys.generic),
    );
  });

  test('returns cancelled when picker returns null', () async {
    when(
      () => picker.pickImage(source: ImageSource.camera),
    ).thenAnswer((_) async => null);

    final MediaPickResult result = await photoPicker.pickFromCamera();

    expect(result, const MediaPickResult.cancelled());
  });

  test('maps camera permission denial to permissionDenied key', () async {
    when(() => picker.pickImage(source: ImageSource.camera)).thenThrow(
      PlatformException(
        code: 'camera_access_denied',
        message: 'The user did not allow camera access.',
      ),
    );

    final MediaPickResult result = await photoPicker.pickFromCamera();

    expect(
      result,
      const MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.permissionDenied,
      ),
    );
  });

  test('maps no available camera to cameraUnavailable key', () async {
    when(() => picker.pickImage(source: ImageSource.camera)).thenThrow(
      PlatformException(
        code: 'no_available_camera',
        message: 'No cameras available',
      ),
    );

    final MediaPickResult result = await photoPicker.pickFromCamera();

    expect(
      result,
      const MediaPickResult.failure(
        errorKey: MediaPickErrorKeys.cameraUnavailable,
      ),
    );
  });

  test('release drops staged pick bytes without take', () {
    final path = StaffDemoProofPickMemory.instance.stage(const <int>[1, 2, 3]);

    StaffDemoProofPickMemory.instance.release(path);

    expect(StaffDemoProofPickMemory.instance.peek(path), isNull);
  });
}
