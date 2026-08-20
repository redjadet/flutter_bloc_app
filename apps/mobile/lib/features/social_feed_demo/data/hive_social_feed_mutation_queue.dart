import 'dart:async';

import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_mutation_dto.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:storage/storage.dart';

part 'hive_social_feed_mutation_queue_ops.part.dart';
part 'hive_social_feed_mutation_queue_json.part.dart';

enum SocialFeedMutationType { like, comment }

/// Viewer-scoped ordered mutation queue + needsAttention dead-letter list.
class HiveSocialFeedMutationQueue extends HiveRepositoryBase {
  HiveSocialFeedMutationQueue({
    required super.hiveService,
    required this._clock,
  });

  static const String boxNameValue = 'social_feed_mutations_v1';
  static const String _schemaNamespace = 'social_feed_mutations:v1';

  final DateTime Function() _clock;
  final Map<String, Completer<void>> _viewerLocks = <String, Completer<void>>{};

  @override
  String get boxName => boxNameValue;

  @override
  HiveBoxSchema? get schema => HiveBoxSchema(
    boxName: boxName,
    namespace: _schemaNamespace,
    fingerprint: hiveSchemaFingerprints[_schemaNamespace] ?? 'dev-untracked',
  );

  String _queueKey(SocialFeedViewer viewer) => 'queue:${viewer.id}';
  String _attentionKey(SocialFeedViewer viewer) => 'attention:${viewer.id}';
  String _seqKey(SocialFeedViewer viewer) => 'seq:${viewer.id}';

  Future<T> _withViewerLock<T>(
    SocialFeedViewer viewer,
    Future<T> Function() action,
  ) async {
    final Completer<void>? previous = _viewerLocks[viewer.id];
    final Completer<void> gate = Completer<void>();
    _viewerLocks[viewer.id] = gate;
    if (previous != null) {
      try {
        await previous.future;
      } on Object {
        // Prior critical section failed; continue safely.
      }
    }
    try {
      return await action();
    } finally {
      if (!gate.isCompleted) {
        gate.complete();
      }
      if (identical(_viewerLocks[viewer.id], gate)) {
        _viewerLocks.remove(viewer.id);
      }
    }
  }

  Future<List<SocialFeedMutationDto>> readQueue(SocialFeedViewer viewer) async {
    return _readList(_queueKey(viewer));
  }

  Future<List<SocialFeedMutationDto>> readNeedsAttention(
    SocialFeedViewer viewer,
  ) async {
    return _readList(_attentionKey(viewer));
  }

  Future<List<SocialFeedMutationDto>> _readList(String key) async {
    return runWithBox((box) async {
      final Object? raw = box.get(key);
      if (raw is! List) {
        return <SocialFeedMutationDto>[];
      }
      final List<SocialFeedMutationDto> out = <SocialFeedMutationDto>[];
      for (final Object? item in raw) {
        if (item is! Map) {
          continue;
        }
        final Map<String, Object?> json = item.map(
          (k, v) => MapEntry(k.toString(), v),
        );
        try {
          out.add(_fromJson(json));
        } on Object {
          // Ignore corrupt record only.
        }
      }
      return out;
    });
  }

  Future<void> _writeList(String key, List<SocialFeedMutationDto> items) async {
    await runWithBox((box) async {
      await box.put(key, <Map<String, Object?>>[
        for (final SocialFeedMutationDto item in items) _toJson(item),
      ]);
    });
  }

  Future<int> _nextSequence(SocialFeedViewer viewer) async {
    return runWithBox((box) async {
      final Object? raw = box.get(_seqKey(viewer));
      final int next = (raw is int ? raw : 0) + 1;
      await box.put(_seqKey(viewer), next);
      return next;
    });
  }

  Duration backoffForAttempt(int attemptCount) {
    // attemptCount after failure: 1→1s, 2→2s, 3→4s, 4→8s (attempts 2–5 waits)
    return switch (attemptCount) {
      1 => const Duration(seconds: 1),
      2 => const Duration(seconds: 2),
      3 => const Duration(seconds: 4),
      _ => const Duration(seconds: 8),
    };
  }

  DateTime now() => _clock().toUtc();
}
