import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_message.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_messages_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthRepo implements AuthRepository {
  _AuthRepo(this._user);

  final AuthUser? _user;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();
}

class _InboxRepo implements StaffDemoInboxRepository {
  _InboxRepo({
    required this.recipients,
    required this.messages,
    this.shiftStatuses = const <String, String>{},
  });

  final List<StaffDemoInboxRecipientSnapshot> recipients;
  final Map<String, StaffDemoInboxMessage> messages;
  final Map<String, String> shiftStatuses;
  final List<String> loadShiftStatusCalls = <String>[];

  @override
  Stream<List<StaffDemoInboxRecipientSnapshot>> watchRecipients({
    required String userId,
  }) => Stream<List<StaffDemoInboxRecipientSnapshot>>.value(recipients);

  @override
  Future<StaffDemoInboxMessage?> loadMessage(String messageId) async =>
      messages[messageId];

  @override
  Future<String?> loadShiftStatus(String shiftId) async {
    loadShiftStatusCalls.add(shiftId);
    return shiftStatuses[shiftId];
  }
}

class _MessagingRepo implements StaffDemoMessagingRepository {
  @override
  Future<void> confirmShiftAssignment({
    required String messageId,
    required String shiftId,
  }) async {}

  @override
  Future<String> sendShiftAssignment({
    required String toUserId,
    required String body,
    required String siteId,
    required DateTime startAtUtc,
    required DateTime endAtUtc,
    required String timezoneName,
  }) async => 'msg-noop';
}

class _ProfileRepo implements StaffDemoProfileRepository {
  @override
  Future<List<StaffDemoProfile>> listAssignableStaff() async =>
      const <StaffDemoProfile>[];

  @override
  Future<StaffDemoProfile?> loadProfile({required String userId}) async => null;
}

void main() {
  group('StaffDemoMessagesCubit', () {
    test('hydrates typed message into inbox item', () async {
      final inbox = _InboxRepo(
        recipients: const <StaffDemoInboxRecipientSnapshot>[
          StaffDemoInboxRecipientSnapshot(messageId: 'm1'),
        ],
        messages: const <String, StaffDemoInboxMessage>{
          'm1': StaffDemoInboxMessage(
            body: 'Hello',
            type: 'shift_assignment',
            shiftId: 's1',
          ),
        },
        shiftStatuses: const <String, String>{'s1': 'pending'},
      );
      final cubit = StaffDemoMessagesCubit(
        authRepository: _AuthRepo(const AuthUser(id: 'u1', isAnonymous: false)),
        inboxRepository: inbox,
        messagingRepository: _MessagingRepo(),
        profileRepository: _ProfileRepo(),
      );

      await cubit.initialize();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, StaffDemoMessagesStatus.ready);
      expect(cubit.state.items, hasLength(1));
      expect(cubit.state.items.single.body, 'Hello');
      expect(cubit.state.items.single.type, 'shift_assignment');
      expect(cubit.state.items.single.shiftId, 's1');
      expect(cubit.state.items.single.shiftStatus, 'pending');
      expect(inbox.loadShiftStatusCalls, <String>['s1']);
      await cubit.close();
    });

    test('skips loadShiftStatus when shiftId is blank or null', () async {
      final inbox = _InboxRepo(
        recipients: const <StaffDemoInboxRecipientSnapshot>[
          StaffDemoInboxRecipientSnapshot(messageId: 'm1'),
          StaffDemoInboxRecipientSnapshot(messageId: 'm2'),
        ],
        messages: const <String, StaffDemoInboxMessage>{
          'm1': StaffDemoInboxMessage(body: 'a', type: 't', shiftId: null),
          'm2': StaffDemoInboxMessage(body: 'b', type: 't', shiftId: ''),
        },
      );
      final cubit = StaffDemoMessagesCubit(
        authRepository: _AuthRepo(const AuthUser(id: 'u1', isAnonymous: false)),
        inboxRepository: inbox,
        messagingRepository: _MessagingRepo(),
        profileRepository: _ProfileRepo(),
      );

      await cubit.initialize();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, StaffDemoMessagesStatus.ready);
      expect(cubit.state.items, hasLength(2));
      expect(inbox.loadShiftStatusCalls, isEmpty);
      await cubit.close();
    });
  });
}
