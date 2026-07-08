import 'package:flutter_bloc_app/app/firebase/run_with_auth_user.dart';

class _BadRemoteTodoRepository {
  Future<List<String>> fetchAll() async => _executeForUser<List<String>>(
    operation: 'fetchAll',
    action: (final user) async => <String>[],
    onFailureFallback: () async => <String>[],
  );
}
