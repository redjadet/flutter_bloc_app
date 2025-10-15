import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';

abstract class AppInfoRepository {
  Future<AppInfo> load();
}
