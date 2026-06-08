import 'dart:io';

Future<String> createTestTempRoot() async {
  final Directory tempRoot = await Directory.systemTemp.createTemp(
    'flutter_bloc_app_test_',
  );
  return tempRoot.path;
}
