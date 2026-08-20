import 'package:meta/meta.dart';

/// Fictional demo viewer identity (no real auth).
@immutable
class const SocialFeedViewer({
  required final String id,
  required final String displayName,
}) {
  static const SocialFeedViewer alex = SocialFeedViewer(
    id: 'demo-alex',
    displayName: 'Alex',
  );

  static const SocialFeedViewer sam = SocialFeedViewer(
    id: 'demo-sam',
    displayName: 'Sam',
  );

  static const List<SocialFeedViewer> demoViewers = <SocialFeedViewer>[
    alex,
    sam,
  ];

  @override
  bool operator ==(Object other) => other is SocialFeedViewer && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
