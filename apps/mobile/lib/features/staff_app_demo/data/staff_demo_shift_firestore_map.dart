import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift.dart';

/// Parses a single `staffDemoShifts/{shiftId}` document if it is active for
/// [userId] at [nowUtc] (`startAt <= nowUtc <= endAt`, required fields present).
///
/// Call sites that already filter with a Firestore query may omit redundant
/// checks; this function is safe to use on arbitrary documents (e.g. seed
/// contract tests).
StaffDemoShift? staffDemoActiveShiftFromFirestoreDoc({
  required final String shiftId,
  required final String userId,
  required final Map<String, dynamic> data,
  required final DateTime nowUtc,
}) {
  final docUserId = (data['userId'] as String?)?.trim();
  if (docUserId == null || docUserId.isEmpty || docUserId != userId) {
    return null;
  }

  final endAtRaw = data['endAt'];
  final siteId = (data['siteId'] as String?)?.trim();
  final tz = (data['timezoneName'] as String?)?.trim();
  if (siteId == null || siteId.isEmpty) return null;
  if (tz == null || tz.isEmpty) return null;
  if (endAtRaw is! Timestamp) return null;
  final endAtUtc = endAtRaw.toDate().toUtc();
  if (nowUtc.isAfter(endAtUtc)) return null;

  final startAtRaw = data['startAt'];
  if (startAtRaw is! Timestamp) return null;
  final startAtUtc = startAtRaw.toDate().toUtc();
  if (startAtUtc.isAfter(nowUtc)) return null;

  return StaffDemoShift(
    shiftId: shiftId,
    userId: userId,
    siteId: siteId,
    startAtUtc: startAtUtc,
    endAtUtc: endAtUtc,
    timezoneName: tz,
  );
}
