import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/routes_carrier_line_demo.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/data/stub_carrier_realtime_client.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/data/stub_line_status_repository.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_repository.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/no_op_fcm_messaging_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _EmptyInbox implements CarrierInboxRepository {
  @override
  Future<List<CarrierInboxItem>> fetchAll() async => const <CarrierInboxItem>[];

  @override
  Stream<List<CarrierInboxItem>> watchAll() async* {
    yield const <CarrierInboxItem>[];
  }

  @override
  Future<void> save(CarrierInboxItem item) async {}

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> ensureSeeded() async {}
}

void main() {
  test('acceptance: carrier-line-demo route builds with DI-shaped factory', () {
    final RouteBase route = CarrierLineDemoRouteFactory(
      inboxRepository: _EmptyInbox(),
      createRealtimeClient: () =>
          StubCarrierRealtimeClient(connectDelay: Duration.zero),
      lineStatusRepository: const StubLineStatusRepository(),
      fcmMessagingService: NoOpFcmMessagingService(),
    ).createRoute();

    expect(route, isA<GoRoute>());
    final GoRoute goRoute = route as GoRoute;
    expect(goRoute.path, AppRoutes.carrierLineDemoPath);
    expect(goRoute.name, AppRoutes.carrierLineDemo);
  });
}
