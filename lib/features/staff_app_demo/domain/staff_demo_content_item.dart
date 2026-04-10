import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_content_item.freezed.dart';

enum StaffDemoContentType { pdf, video }

@freezed
abstract class StaffDemoContentItem with _$StaffDemoContentItem {
  const factory StaffDemoContentItem({
    required final String contentId,
    required final String title,
    required final StaffDemoContentType type,
    required final String storagePath,
    required final bool isPublished,
  }) = _StaffDemoContentItem;
}
