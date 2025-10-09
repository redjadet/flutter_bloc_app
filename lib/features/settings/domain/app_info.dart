import 'package:equatable/equatable.dart';

class AppInfo extends Equatable {
  const AppInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  @override
  List<Object> get props => <Object>[version, buildNumber];
}
