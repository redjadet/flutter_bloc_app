import 'package:flutter_bloc_app/features/online_therapy_demo/domain/online_therapy_network_mode.dart';

/// Demo-only control surface for fake network simulation (composition root passes data impl).
abstract interface class OnlineTherapyNetworkModeController {
  OnlineTherapyNetworkMode get mode;

  set mode(OnlineTherapyNetworkMode value);
}
