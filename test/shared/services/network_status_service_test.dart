import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityNetworkStatusService', () {
    late _MockConnectivity connectivity;
    late ConnectivityNetworkStatusService service;
    late StreamController<List<ConnectivityResult>> controller;

    setUp(() {
      connectivity = _MockConnectivity();
      controller = StreamController<List<ConnectivityResult>>.broadcast();
      when(
        () => connectivity.onConnectivityChanged,
      ).thenAnswer((_) => controller.stream);
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
      service = ConnectivityNetworkStatusService(
        connectivity: connectivity,
        debounce: Duration.zero,
      );
    });

    tearDown(() async {
      await service.dispose();
      await controller.close();
    });

    test('emits statuses based on connectivity stream', () async {
      final List<NetworkStatus> events = <NetworkStatus>[];
      final StreamSubscription<NetworkStatus> subscription = service
          .statusStream
          .listen(events.add);

      controller.add(<ConnectivityResult>[ConnectivityResult.wifi]);
      await Future<void>.delayed(const Duration(milliseconds: 1));
      controller.add(<ConnectivityResult>[ConnectivityResult.none]);
      await Future<void>.delayed(const Duration(milliseconds: 1));
      controller.add(<ConnectivityResult>[ConnectivityResult.ethernet]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(events, <NetworkStatus>[
        NetworkStatus.online,
        NetworkStatus.offline,
        NetworkStatus.online,
      ]);
      await subscription.cancel();
    });

    test('getCurrentStatus returns normalized value', () async {
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);

      final NetworkStatus status = await service.getCurrentStatus();
      expect(status, NetworkStatus.offline);
    });
  });
}
