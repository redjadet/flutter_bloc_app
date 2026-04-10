import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';

class FirestoreStaffDemoContentRepository
    implements StaffDemoContentRepository {
  FirestoreStaffDemoContentRepository({
    required final FirebaseFirestore firestore,
    required final FirebaseStorage? storage,
  }) : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage? _storage;

  @override
  Future<List<StaffDemoContentItem>> listPublished() async {
    final snap = await _firestore
        .collection('staffDemoContent')
        .where('isPublished', isEqualTo: true)
        .orderBy('title')
        .limit(200)
        .get();

    return snap.docs
        .map((d) => _mapItem(d.id, d.data()))
        .where((e) => e != null)
        .cast<StaffDemoContentItem>()
        .toList(growable: false);
  }

  StaffDemoContentItem? _mapItem(
    final String contentId,
    final Map<String, dynamic> data,
  ) {
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

  @override
  Future<Uri> getDownloadUrl({required final String storagePath}) async {
    final storage = _storage;
    if (storage == null) {
      throw StateError('Firebase Storage unavailable');
    }
    final url = await storage.ref(storagePath).getDownloadURL();
    return Uri.parse(url);
  }
}
