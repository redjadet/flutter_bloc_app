part of 'online_therapy_fake_api.dart';

extension OnlineTherapyFakeApiCallsAdmin on OnlineTherapyFakeApi {
  Future<CallSession> createCallSession({
    required final String appointmentId,
  }) async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    final appt = _appointments.firstWhere((a) => a.id == appointmentId);
    final canCreate =
        user.role == TherapyRole.admin ||
        (user.role == TherapyRole.client && appt.clientId == user.id) ||
        (user.role == TherapyRole.therapist &&
            _isTherapistOwner(userId: user.id, therapistId: appt.therapistId));
    if (!canCreate) throw StateError('Not allowed');

    final call = CallSession(
      id: 'call_${_calls.length + 1}',
      appointmentId: appointmentId,
      roomId: 'room_$appointmentId',
      provider: CallProvider.simulated,
      joinStatus: CallJoinStatus.preparing,
    );
    _calls.add(call);
    _appendAudit('call_session_created', targetId: call.id);
    return call;
  }

  Future<CallSession> joinCall({required final String callSessionId}) async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    final idx = _calls.indexWhere((c) => c.id == callSessionId);
    if (idx < 0) throw StateError('Call session not found');
    final current = _calls[idx];
    final appt = _appointments.firstWhere((a) => a.id == current.appointmentId);
    final canJoin =
        user.role == TherapyRole.admin ||
        (user.role == TherapyRole.client && appt.clientId == user.id) ||
        (user.role == TherapyRole.therapist &&
            _isTherapistOwner(userId: user.id, therapistId: appt.therapistId));
    if (!canJoin) throw StateError('Not allowed');

    if (mode == OnlineTherapyNetworkMode.callFailure) {
      final failed = CallSession(
        id: current.id,
        appointmentId: current.appointmentId,
        roomId: current.roomId,
        provider: current.provider,
        joinStatus: CallJoinStatus.failed,
      );
      _calls[idx] = failed;
      _appendAudit('call_join_failed', targetId: failed.id);
      return failed;
    }

    final connected = CallSession(
      id: current.id,
      appointmentId: current.appointmentId,
      roomId: current.roomId,
      provider: current.provider,
      joinStatus: CallJoinStatus.connected,
    );
    _calls[idx] = connected;
    _appendAudit('call_joined', targetId: connected.id);
    return connected;
  }

  Future<List<TherapistProfile>> listPendingTherapists() async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    _requireRole(user, allowed: <TherapyRole>[TherapyRole.admin]);
    return _therapists.where((t) => !t.isVerified).toList(growable: false);
  }

  Future<TherapistProfile> approveTherapist({
    required final String therapistId,
  }) async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    _requireRole(user, allowed: <TherapyRole>[TherapyRole.admin]);

    final idx = _therapists.indexWhere((t) => t.id == therapistId);
    if (idx < 0) throw StateError('Therapist not found');
    final current = _therapists[idx];
    final updated = TherapistProfile(
      id: current.id,
      userId: current.userId,
      title: current.title,
      specialties: current.specialties,
      languages: current.languages,
      bio: current.bio,
      rating: current.rating,
      isVerified: true,
    );
    _therapists[idx] = updated;
    _appendAudit('therapist_approved', targetId: updated.id);
    return updated;
  }

  Future<List<AuditEvent>> listAuditEvents() async {
    await _simulateNetwork();
    _requireCurrentUser();
    return _audit.toList(growable: false);
  }
}

// eof
