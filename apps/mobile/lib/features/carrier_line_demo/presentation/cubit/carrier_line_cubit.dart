import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_connection_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_repository.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_realtime_client.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status_repository.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/cubit/carrier_line_state.dart';
import 'package:utilities/utilities.dart';

/// Presentation orchestrator for the business-line demo surface.
///
/// [fcmMessagingService] is composed for P1 push UI readiness; P0 does not
/// expose interactive push registration.
class CarrierLineCubit({
  required final CarrierInboxRepository inboxRepository,
  required final CarrierRealtimeClient realtimeClient,
  required final LineStatusRepository lineStatusRepository,
  required final FcmMessagingService fcmMessagingService,
}) extends Cubit<CarrierLineState> {
  this : super(CarrierLineState.initial());

  StreamSubscription<List<CarrierInboxItem>>? _inboxSub;
  StreamSubscription<CarrierConnectionStatus>? _connectionSub;

  Future<void> start() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _inboxSub?.cancel();
    await _connectionSub?.cancel();

    try {
      await inboxRepository.ensureSeeded();
      final LineStatusSnapshot lineStatus = await lineStatusRepository.fetch();
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          lineStatus: lineStatus,
          connection: realtimeClient.currentStatus,
          connectionError: realtimeClient.lastError,
        ),
      );
    } on Object catch (error) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
      return;
    }

    _inboxSub = inboxRepository.watchAll().listen(
      (items) {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(isLoading: false, inbox: items, clearError: true));
      },
      onError: (Object error) {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
      },
    );

    _connectionSub = realtimeClient.connectionStates.listen((status) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          connection: status,
          connectionError: realtimeClient.lastError,
          clearConnectionError: realtimeClient.lastError == null,
        ),
      );
    });
  }

  Future<void> connectRealtime() => realtimeClient.connect();

  Future<void> disconnectRealtime() => realtimeClient.disconnect();

  Future<void> markRead(String id) async {
    try {
      await inboxRepository.markRead(id);
      if (!isClosed) {
        emit(state.copyWith(clearError: true));
      }
    } on Object catch (error) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _inboxSub?.cancel();
    await _connectionSub?.cancel();
    await realtimeClient.dispose();
    await super.close();
  }
}
