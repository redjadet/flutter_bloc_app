import 'package:flutter_bloc_app/app/composition/features/register_fcm_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/no_op_fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test('registerFcmDemoServices uses no-op service when Firebase absent', () {
    registerFcmDemoServices();

    final service = getIt<FcmMessagingService>();
    expect(service, isA<NoOpFcmMessagingService>());
  });
}
