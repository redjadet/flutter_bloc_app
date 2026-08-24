part of 'hive_social_feed_mutation_queue.dart';

extension HiveSocialFeedMutationQueueOps on HiveSocialFeedMutationQueue {
  Future<SocialFeedMutationDto> enqueueLike({
    required SocialFeedViewer viewer,
    required String postId,
    required bool desiredLiked,
    required String mutationId,
  }) {
    return _withViewerLock(viewer, () async {
      final List<SocialFeedMutationDto> queue = await readQueue(viewer);
      // Coalesce adjacent undispatched likes for same post.
      if (queue.isNotEmpty) {
        final SocialFeedMutationDto last = queue.last;
        if (!last.dispatched &&
            last.type == 'like' &&
            last.postId == postId &&
            last.viewerId == viewer.id) {
          final SocialFeedMutationDto coalesced = SocialFeedMutationDto(
            mutationId: mutationId,
            viewerId: viewer.id,
            type: 'like',
            postId: postId,
            sequence: last.sequence,
            idempotencyKey: last.idempotencyKey,
            attemptCount: last.attemptCount,
            nextAttemptAt: last.nextAttemptAt,
            desiredLiked: desiredLiked,
            commentBody: null,
            status: 'pending',
            dispatched: false,
          );
          queue[queue.length - 1] = coalesced;
          await _writeList(_queueKey(viewer), queue);
          return coalesced;
        }
      }

      final int sequence = await _nextSequence(viewer);
      final SocialFeedMutationDto dto = SocialFeedMutationDto(
        mutationId: mutationId,
        viewerId: viewer.id,
        type: 'like',
        postId: postId,
        sequence: sequence,
        idempotencyKey: mutationId,
        attemptCount: 0,
        nextAttemptAt: null,
        desiredLiked: desiredLiked,
        commentBody: null,
        status: 'pending',
        dispatched: false,
      );
      queue.add(dto);
      await _writeList(_queueKey(viewer), queue);
      return dto;
    });
  }

  Future<SocialFeedMutationDto> enqueueComment({
    required SocialFeedViewer viewer,
    required String postId,
    required String body,
    required String mutationId,
  }) {
    return _withViewerLock(viewer, () async {
      final int sequence = await _nextSequence(viewer);
      final SocialFeedMutationDto dto = SocialFeedMutationDto(
        mutationId: mutationId,
        viewerId: viewer.id,
        type: 'comment',
        postId: postId,
        sequence: sequence,
        idempotencyKey: mutationId,
        attemptCount: 0,
        nextAttemptAt: null,
        desiredLiked: null,
        commentBody: body,
        status: 'pending',
        dispatched: false,
      );
      final List<SocialFeedMutationDto> queue = await readQueue(viewer);
      queue.add(dto);
      await _writeList(_queueKey(viewer), queue);
      return dto;
    });
  }

  Future<void> replaceQueue(
    SocialFeedViewer viewer,
    List<SocialFeedMutationDto> queue,
  ) => _withViewerLock(viewer, () => _writeList(_queueKey(viewer), queue));

  Future<void> replaceNeedsAttention(
    SocialFeedViewer viewer,
    List<SocialFeedMutationDto> items,
  ) => _withViewerLock(viewer, () => _writeList(_attentionKey(viewer), items));

  /// Atomically bumps backoff for one queued mutation (read-modify-write under lock).
  Future<void> updateMutationAfterFailure({
    required SocialFeedViewer viewer,
    required String mutationId,
    required SocialFeedMutationDto head,
    required int attemptCount,
    required DateTime nextAttemptAt,
  }) {
    return _withViewerLock(viewer, () async {
      final List<SocialFeedMutationDto> queue = await readQueue(viewer);
      final int idx = queue.indexWhere((e) => e.mutationId == mutationId);
      if (idx < 0) {
        return;
      }
      queue[idx] = SocialFeedMutationDto(
        mutationId: head.mutationId,
        viewerId: head.viewerId,
        type: head.type,
        postId: head.postId,
        sequence: head.sequence,
        idempotencyKey: head.idempotencyKey,
        attemptCount: attemptCount,
        nextAttemptAt: nextAttemptAt.toIso8601String(),
        desiredLiked: head.desiredLiked,
        commentBody: head.commentBody,
        status: 'pending',
        dispatched: false,
      );
      await _writeList(_queueKey(viewer), queue);
    });
  }

  Future<void> moveToNeedsAttention(
    SocialFeedViewer viewer,
    SocialFeedMutationDto item,
  ) async {
    await _withViewerLock(viewer, () async {
      final List<SocialFeedMutationDto> queue = await readQueue(viewer)
        ..removeWhere(
          (e) => e.mutationId == item.mutationId,
        );
      await _writeList(_queueKey(viewer), queue);
      final List<SocialFeedMutationDto> attention = await readNeedsAttention(
        viewer,
      );
      attention.add(
        SocialFeedMutationDto(
          mutationId: item.mutationId,
          viewerId: item.viewerId,
          type: item.type,
          postId: item.postId,
          sequence: item.sequence,
          idempotencyKey: item.idempotencyKey,
          attemptCount: item.attemptCount,
          nextAttemptAt: null,
          desiredLiked: item.desiredLiked,
          commentBody: item.commentBody,
          status: 'needsAttention',
          dispatched: item.dispatched,
        ),
      );
      await _writeList(_attentionKey(viewer), attention);
    });
  }

  Future<void> manualRetry({
    required SocialFeedViewer viewer,
    required String mutationId,
  }) async {
    await _withViewerLock(viewer, () async {
      final List<SocialFeedMutationDto> attention = await readNeedsAttention(
        viewer,
      );
      final int index = attention.indexWhere((e) => e.mutationId == mutationId);
      if (index < 0) {
        return;
      }
      final SocialFeedMutationDto item = attention.removeAt(index);
      await _writeList(_attentionKey(viewer), attention);
      final List<SocialFeedMutationDto> queue = await readQueue(viewer);
      queue.add(
        SocialFeedMutationDto(
          mutationId: item.mutationId,
          viewerId: item.viewerId,
          type: item.type,
          postId: item.postId,
          sequence: item.sequence,
          idempotencyKey: item.idempotencyKey,
          attemptCount: 0,
          nextAttemptAt: null,
          desiredLiked: item.desiredLiked,
          commentBody: item.commentBody,
          status: 'pending',
          dispatched: false,
        ),
      );
      await _writeList(_queueKey(viewer), queue);
    });
  }

  Future<void> removeFromQueue({
    required SocialFeedViewer viewer,
    required String mutationId,
  }) async {
    await _withViewerLock(viewer, () async {
      final List<SocialFeedMutationDto> queue = await readQueue(viewer)
        ..removeWhere((e) => e.mutationId == mutationId);
      await _writeList(_queueKey(viewer), queue);
    });
  }

  Future<void> clearViewer(SocialFeedViewer viewer) async {
    await _withViewerLock(viewer, () async {
      await runWithBox((box) async {
        await safeDeleteKey(box, _queueKey(viewer));
        await safeDeleteKey(box, _attentionKey(viewer));
        await safeDeleteKey(box, _seqKey(viewer));
      });
    });
  }
}
