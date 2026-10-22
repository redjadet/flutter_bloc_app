import 'package:cloud_firestore/cloud_firestore.dart';

class BadSdkDomain {
  const BadSdkDomain(this.snapshot);

  final DocumentSnapshot<Object?> snapshot;
}
