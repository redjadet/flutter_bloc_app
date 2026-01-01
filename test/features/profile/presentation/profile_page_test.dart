import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/profile/profile.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _testUser = ProfileUser(
  name: 'Jane',
  location: 'San Francisco, CA',
  avatarUrl: 'https://example.com/avatar.png',
  galleryImages: [
    ProfileImage(url: 'https://example.com/1.png', aspectRatio: 0.71),
    ProfileImage(url: 'https://example.com/2.png', aspectRatio: 1.41),
    ProfileImage(url: 'https://example.com/3.png', aspectRatio: 1.0),
    ProfileImage(url: 'https://example.com/4.png', aspectRatio: 1.3),
  ],
);

Future<void> _pumpProfilePage(
  final WidgetTester tester, {
  required final ProfileRepository repository,
  SyncStatusCubit? syncStatusCubit,
}) async {
  final SyncStatusCubit cubit =
      syncStatusCubit ??
      SyncStatusCubit(
        networkStatusService: _FakeNetworkStatusService(),
        coordinator: _FakeBackgroundSyncCoordinator(),
      );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  ProfileCubit(repository: repository)..loadProfile(),
            ),
            BlocProvider<SyncStatusCubit>.value(value: cubit),
          ],
          child: const ProfilePage(),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

Future<void> _resolveAsyncWork(final WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

class _SuccessProfileRepository implements ProfileRepository {
  const _SuccessProfileRepository();

  @override
  Future<ProfileUser> getProfile() async => _testUser;
}

class _FlakyProfileRepository implements ProfileRepository {
  int _calls = 0;

  @override
  Future<ProfileUser> getProfile() async {
    _calls++;
    if (_calls == 1) {
      throw Exception('network down');
    }
    return _testUser;
  }
}

class _FakeNetworkStatusService implements NetworkStatusService {
  _FakeNetworkStatusService();

  NetworkStatus status = NetworkStatus.online;
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream;

  @override
  Future<NetworkStatus> getCurrentStatus() async => status;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  void emit(final NetworkStatus newStatus) {
    status = newStatus;
    _controller.add(newStatus);
  }
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  _FakeBackgroundSyncCoordinator();

  SyncStatus status = SyncStatus.idle;
  final StreamController<SyncStatus> _controller =
      StreamController<SyncStatus>.broadcast();

  @override
  Stream<SyncStatus> get statusStream => _controller.stream;

  @override
  SyncStatus get currentStatus => status;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Future<void> start() async {}

  @override
  Future<void> ensureStarted() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> flush() async {}

  void emit(final SyncStatus newStatus) {
    status = newStatus;
    _controller.add(newStatus);
  }
}

void main() {
  group('ProfilePage', () {
    testWidgets('renders loading then profile content', (final tester) async {
      await _pumpProfilePage(
        tester,
        repository: const _SuccessProfileRepository(),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await _resolveAsyncWork(tester);

      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('SAN FRANCISCO, CA'), findsOneWidget);
      expect(find.text('FOLLOW JANE'), findsOneWidget);
      expect(find.text('MESSAGE'), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('SEE MORE'),
        find.byType(CustomScrollView),
        const Offset(0, -200),
      );
      expect(find.text('SEE MORE'), findsOneWidget);
    });

    testWidgets('shows sync banner when offline', (final tester) async {
      final _FakeNetworkStatusService networkService =
          _FakeNetworkStatusService()..status = NetworkStatus.offline;
      final _FakeBackgroundSyncCoordinator coordinator =
          _FakeBackgroundSyncCoordinator();
      networkService.emit(NetworkStatus.offline);
      final SyncStatusCubit syncCubit = SyncStatusCubit(
        networkStatusService: networkService,
        coordinator: coordinator,
      );

      await _pumpProfilePage(
        tester,
        repository: const _SuccessProfileRepository(),
        syncStatusCubit: syncCubit,
      );

      await _resolveAsyncWork(tester);

      expect(find.byType(ProfileSyncBanner), findsOneWidget);
    });

    testWidgets('displays profile sections', (final tester) async {
      await _pumpProfilePage(
        tester,
        repository: const _SuccessProfileRepository(),
      );
      await _resolveAsyncWork(tester);

      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.byType(ProfileActionButtons), findsOneWidget);
      expect(find.byType(ProfileGallery, skipOffstage: false), findsOneWidget);
      expect(find.byType(ProfileBottomNav), findsOneWidget);
    });

    testWidgets('shows retry view when loading fails', (final tester) async {
      final repository = _FlakyProfileRepository();
      await _pumpProfilePage(tester, repository: repository);
      await _resolveAsyncWork(tester);

      expect(find.text('Failed to load profile'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      await tester.tap(find.text('TRY AGAIN'));
      await _resolveAsyncWork(tester);

      expect(find.text('Jane'), findsOneWidget);
    });
  });
}
