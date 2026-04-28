import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/audit_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_admin_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class AdminState {
  const AdminState({
    required this.isBusy,
    required this.pendingTherapists,
    required this.auditEvents,
    this.errorMessage,
  });

  final bool isBusy;
  final List<TherapistProfile> pendingTherapists;
  final List<AuditEvent> auditEvents;
  final String? errorMessage;

  AdminState copyWith({
    bool? isBusy,
    List<TherapistProfile>? pendingTherapists,
    List<AuditEvent>? auditEvents,
    String? errorMessage,
  }) => AdminState(
    isBusy: isBusy ?? this.isBusy,
    pendingTherapists: pendingTherapists ?? this.pendingTherapists,
    auditEvents: auditEvents ?? this.auditEvents,
    errorMessage: errorMessage,
  );
}

class AdminCubit extends Cubit<AdminState> {
  AdminCubit({
    required final TherapyAdminRepository admin,
    required final AuditRepository audit,
  }) : _admin = admin,
       _audit = audit,
       super(
         const AdminState(
           isBusy: false,
           pendingTherapists: <TherapistProfile>[],
           auditEvents: <AuditEvent>[],
         ),
       );

  final TherapyAdminRepository _admin;
  final AuditRepository _audit;

  Future<void> refresh() async {
    emit(state.copyWith(isBusy: true));
    try {
      final list = await _admin.listPendingTherapists();
      final auditEvents = await _audit.listEvents();
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          pendingTherapists: list,
          auditEvents: auditEvents,
        ),
      );
    } on Object catch (e, st) {
      AppLogger.error('AdminCubit.refresh failed', e, st);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> approve(final String therapistId) async {
    emit(state.copyWith(isBusy: true));
    try {
      await _admin.approveTherapist(therapistId: therapistId);
      final list = await _admin.listPendingTherapists();
      final auditEvents = await _audit.listEvents();
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          pendingTherapists: list,
          auditEvents: auditEvents,
        ),
      );
    } on Object catch (e, st) {
      AppLogger.error('AdminCubit.approve failed', e, st);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }
}
