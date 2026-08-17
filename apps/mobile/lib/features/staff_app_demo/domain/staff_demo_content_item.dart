import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_content_item.freezed.dart';

enum StaffDemoContentType { pdf, video }

@freezed
abstract class StaffDemoContentItem with _$StaffDemoContentItem {
  const factory StaffDemoContentItem({
    required String contentId,
    required String title,
    required StaffDemoContentType type,
    required String storagePath,
    required bool isPublished,
  }) = _StaffDemoContentItem;
}
