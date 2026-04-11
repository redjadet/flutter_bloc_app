import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';

abstract interface class StaffDemoContentRepository {
  Future<List<StaffDemoContentItem>> listPublished();

  Future<Uri> getDownloadUrl({required String storagePath});
}
