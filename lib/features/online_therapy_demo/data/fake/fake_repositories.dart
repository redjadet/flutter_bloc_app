import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/repositories.dart';

class FakeTherapyAuthRepository implements TherapyAuthRepository {
  FakeTherapyAuthRepository({required final OnlineTherapyFakeApi api})
    : _api = api;

  final OnlineTherapyFakeApi _api;

  @override
  TherapyUser? get currentUser => _api.currentUser;

  @override
  Future<TherapyUser> login({
    required final String email,
    required final TherapyRole role,
  }) => _api.login(email: email, role: role);

  @override
  Future<void> logout() => _api.logout();
}

class FakeTherapistRepository implements TherapistRepository {
  FakeTherapistRepository({required final OnlineTherapyFakeApi api})
    : _api = api;

  final OnlineTherapyFakeApi _api;

  @override
  Future<TherapistProfile> getTherapist({required final String therapistId}) =>
      _api.getTherapist(therapistId: therapistId);

  @override
  Future<List<TherapistProfile>> listTherapists({
    final String? query,
    final String? specialty,
    final String? language,
  }) => _api.listTherapists(
    query: query,
    specialty: specialty,
    language: language,
  );

  @override
  Future<List<AvailabilitySlot>> listAvailability({
    required final String therapistId,
    required final DateTime date,
  }) => _api.listAvailability(therapistId: therapistId, date: date);
}

class FakeAppointmentRepository implements AppointmentRepository {
  FakeAppointmentRepository({required final OnlineTherapyFakeApi api})
    : _api = api;

  final OnlineTherapyFakeApi _api;

  @override
  Future<Appointment> cancelAppointment({
    required final String appointmentId,
    required final String reason,
  }) => _api.cancelAppointment(appointmentId: appointmentId, reason: reason);

  @override
  Future<Appointment> createAppointment({
    required final String therapistId,
    required final DateTime startAt,
    required final DateTime endAt,
  }) => _api.createAppointment(
    therapistId: therapistId,
    startAt: startAt,
    endAt: endAt,
  );

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() =>
      _api.listAppointmentsForCurrentRole();
}

class FakeTherapyMessagingRepository implements TherapyMessagingRepository {
  FakeTherapyMessagingRepository({required final OnlineTherapyFakeApi api})
    : _api = api;

  final OnlineTherapyFakeApi _api;

  @override
  Future<List<Conversation>> listConversations() => _api.listConversations();

  @override
  Future<List<Message>> listMessages({required final String conversationId}) =>
      _api.listMessages(conversationId: conversationId);

  @override
  Future<Message> retryMessage({required final String messageId}) =>
      _api.retryMessage(messageId: messageId);

  @override
  Future<Message> sendMessage({
    required final String conversationId,
    required final String body,
  }) => _api.sendMessage(conversationId: conversationId, body: body);
}

class FakeTherapyCallRepository implements TherapyCallRepository {
  FakeTherapyCallRepository({required final OnlineTherapyFakeApi api})
    : _api = api;

  final OnlineTherapyFakeApi _api;

  @override
  Future<CallSession> createSession({required final String appointmentId}) =>
      _api.createCallSession(appointmentId: appointmentId);

  @override
  Future<CallSession> join({required final String callSessionId}) =>
      _api.joinCall(callSessionId: callSessionId);
}

class FakeTherapyAdminRepository implements TherapyAdminRepository {
  FakeTherapyAdminRepository({required final OnlineTherapyFakeApi api})
    : _api = api;

  final OnlineTherapyFakeApi _api;

  @override
  Future<TherapistProfile> approveTherapist({
    required final String therapistId,
  }) => _api.approveTherapist(therapistId: therapistId);

  @override
  Future<List<TherapistProfile>> listPendingTherapists() =>
      _api.listPendingTherapists();
}

class FakeAuditRepository implements AuditRepository {
  FakeAuditRepository({required final OnlineTherapyFakeApi api}) : _api = api;

  final OnlineTherapyFakeApi _api;

  @override
  Future<List<AuditEvent>> listEvents() => _api.listAuditEvents();
}
