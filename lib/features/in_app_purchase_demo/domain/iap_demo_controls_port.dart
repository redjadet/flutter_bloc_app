import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';

abstract interface class IapDemoControlsPort {
  void resetDemoState();
}

abstract interface class IapFakeOutcomePort implements IapDemoControlsPort {
  IapDemoForcedOutcome get forcedOutcome;
  set forcedOutcome(IapDemoForcedOutcome value);
}
