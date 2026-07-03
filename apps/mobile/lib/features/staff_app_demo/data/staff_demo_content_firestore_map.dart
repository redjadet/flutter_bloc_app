import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';

/// Parses `staffDemoContent/{contentId}` document data into [StaffDemoContentItem].
StaffDemoContentItem? staffDemoContentItemFromFirestoreMap({
  required final String contentId,
  required final Map<String, dynamic> data,
}) {
  final title = data['title'] as String?;
  final typeRaw = data['type'] as String?;
  final storagePath = data['storagePath'] as String?;
  final isPublished = data['isPublished'] as bool? ?? false;

  if (title == null || title.trim().isEmpty) return null;
  if (storagePath == null || storagePath.trim().isEmpty) return null;

  final StaffDemoContentType? type = switch (typeRaw) {
    'pdf' => StaffDemoContentType.pdf,
    'video' => StaffDemoContentType.video,
    _ => null,
  };
  if (type == null) return null;

  return StaffDemoContentItem(
    contentId: contentId,
    title: title.trim(),
    type: type,
    storagePath: storagePath.trim(),
    isPublished: isPublished,
  );
}
