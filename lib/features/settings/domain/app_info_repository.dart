import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';

mixin AppInfoRepository {
  Future<AppInfo> load();
}
