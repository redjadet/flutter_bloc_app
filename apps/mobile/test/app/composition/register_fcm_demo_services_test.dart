import 'package:flutter_bloc_app/app/composition/features/register_fcm_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/simulated_fcm_messaging_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utilities/utilities.dart';

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test(
    'registerFcmDemoServices uses simulated service when Firebase absent',
    () {
      registerFcmDemoServices();

      final FcmMessagingService service = getIt<FcmMessagingService>();
      expect(service, isA<SimulatedFcmMessagingService>());
      expect(getIt<FcmDemoMode>(), FcmDemoMode.simulated);
      expect(
        getIt<FcmSimulationController>(),
        isA<SimulatedFcmMessagingService>(),
      );
    },
  );
}
