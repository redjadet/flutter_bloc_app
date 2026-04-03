import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart' show FakeTimerService;

/// [Connectivity] is a concrete plugin class; this test double implements the
/// instance surface so we expose a real broadcast stream (mocktail breaks
/// multi-listener fan-out on stubbed getters).
final class _FakeConnectivity implements Connectivity {
  _FakeConnectivity({
    required Stream<List<ConnectivityResult>> onConnectivityChanged,
    this.beforeCheck,
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
  })  : _onConnectivityChanged = onConnectivityChanged,
        _checkConnectivity = checkConnectivity ??
            (() async => <ConnectivityResult>[ConnectivityResult.wifi]);

  Future<void> Function()? beforeCheck;
  final Stream<List<ConnectivityResult>> _onConnectivityChanged;
  Future<List<ConnectivityResult>> Function() _checkConnectivity;

  set checkFn(Future<List<ConnectivityResult>> Function() value) {
    _checkConnectivity = value;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _onConnectivityChanged;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    await beforeCheck?.call();
    return _checkConnectivity();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityNetworkStatusService', () {
    const Duration debounceWindow = Duration(milliseconds: 10);

    group('statusStream', () {
      late _FakeConnectivity connectivity;
      late FakeTimerService timerService;
      late ConnectivityNetworkStatusService service;
      late StreamController<List<ConnectivityResult>> controller;

      setUp(() {
        timerService = FakeTimerService();
        controller = StreamController<List<ConnectivityResult>>.broadcast();
        connectivity = _FakeConnectivity(
          onConnectivityChanged: controller.stream,
          beforeCheck: null,
        );
        service = ConnectivityNetworkStatusService(
          connectivity: connectivity,
          debounce: debounceWindow,
          timerService: timerService,
        );
      });

      tearDown(() async {
        await service.dispose();
        await controller.close();
      });

      test('emits statuses based on connectivity stream', () async {
        final Completer<void> initialCheckGate = Completer<void>();
        connectivity.beforeCheck = () => initialCheckGate.future;

        final List<NetworkStatus> events = <NetworkStatus>[];
        final StreamSubscription<NetworkStatus> subscription = service
            .statusStream
            .listen(events.add);

        initialCheckGate.complete();
        await Future<void>.delayed(Duration.zero);

        controller.add(<ConnectivityResult>[ConnectivityResult.none]);
        await Future<void>.delayed(Duration.zero);

        timerService.elapse(debounceWindow);

        controller.add(<ConnectivityResult>[ConnectivityResult.ethernet]);
        await Future<void>.delayed(Duration.zero);

        timerService.elapse(debounceWindow);
        // Distinct/async stream may deliver the debounced event after the fake
        // timer callback returns; flush before asserting.
        await Future<void>.delayed(Duration.zero);

        expect(events, orderedEquals(<NetworkStatus>[
          NetworkStatus.online,
          NetworkStatus.offline,
          NetworkStatus.online,
        ]));
        await subscription.cancel();
      });

      test('ignores stale initial check after listen session churn', () async {
        final Completer<void> stallFirstCheck = Completer<void>();
        int beforeCheckInvocations = 0;
        connectivity.beforeCheck = () async {
          beforeCheckInvocations++;
          if (beforeCheckInvocations == 1) {
            await stallFirstCheck.future;
          }
        };
        connectivity.checkFn = () async {
          if (!stallFirstCheck.isCompleted) {
            return <ConnectivityResult>[ConnectivityResult.none];
          }
          return <ConnectivityResult>[ConnectivityResult.wifi];
        };

        final List<NetworkStatus> events = <NetworkStatus>[];
        final StreamSubscription<NetworkStatus> first = service.statusStream
            .listen(events.add);
        await Future<void>.delayed(Duration.zero);

        await first.cancel();
        await Future<void>.delayed(Duration.zero);

        final StreamSubscription<NetworkStatus> second = service.statusStream
            .listen(events.add);
        await Future<void>.delayed(Duration.zero);

        stallFirstCheck.complete();
        await Future<void>.delayed(Duration.zero);

        expect(events, orderedEquals(<NetworkStatus>[NetworkStatus.offline]));
        await second.cancel();
      });

      test('statusStream treats mixed connectivity list as online', () async {
        final List<NetworkStatus> events = <NetworkStatus>[];
        final StreamSubscription<NetworkStatus> subscription = service
            .statusStream
            .listen(events.add);

        await Future<void>.delayed(const Duration(milliseconds: 1));

        controller.add(<ConnectivityResult>[
          ConnectivityResult.none,
          ConnectivityResult.mobile,
        ]);
        await Future<void>.delayed(Duration.zero);
        timerService.elapse(debounceWindow);

        expect(events, contains(NetworkStatus.online));
        await subscription.cancel();
      });
    });

    group('getCurrentStatus', () {
      late _FakeConnectivity connectivity;
      late ConnectivityNetworkStatusService service;

      setUp(() {
        connectivity = _FakeConnectivity(
          onConnectivityChanged: const Stream.empty(),
          beforeCheck: null,
        );
        service = ConnectivityNetworkStatusService(
          connectivity: connectivity,
          debounce: debounceWindow,
          timerService: FakeTimerService(),
        );
      });

      tearDown(() async {
        await service.dispose();
      });

      test('returns normalized value', () async {
        connectivity.checkFn = () async => <ConnectivityResult>[
          ConnectivityResult.none,
        ];

        final NetworkStatus status = await service.getCurrentStatus();
        expect(status, NetworkStatus.offline);
      });

      test('returns online for mixed connectivity results', () async {
        connectivity.checkFn = () async => <ConnectivityResult>[
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ];

        final NetworkStatus status = await service.getCurrentStatus();
        expect(status, NetworkStatus.online);
      });
    });
  });
}
