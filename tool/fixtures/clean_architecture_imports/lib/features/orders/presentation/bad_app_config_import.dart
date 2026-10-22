import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';

class BadAppConfigPresentation {
  bool get isProd => FlavorManager.I.isProd;
}
