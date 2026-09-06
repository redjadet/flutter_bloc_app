import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info.freezed.dart';

@freezed
abstract class AppInfo with _$AppInfo {
  const factory({required String version, required String buildNumber}) =
      _AppInfo;
}
