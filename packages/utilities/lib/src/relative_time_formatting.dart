/// Short relative-time labels for chat-style timestamps (e.g. `3d`, `2h`).
String formatRelativeTimeShort(final DateTime time, {final DateTime? now}) {
  final DateTime reference = now ?? DateTime.now();
  final Duration difference = reference.difference(time);

  if (difference.inDays > 0) {
    return '${difference.inDays}d';
  }
  if (difference.inHours > 0) {
    return '${difference.inHours}h';
  }
  if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  }
  return 'now';
}
