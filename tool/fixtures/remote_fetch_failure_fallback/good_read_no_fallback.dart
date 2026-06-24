import 'package:flutter_bloc_app/shared/firebase/run_with_auth_user.dart';

class _GoodRemoteTodoRepository {
  Future<List<String>> fetchAll() async => _executeForUser<List<String>>(
    operation: 'fetchAll',
    action: (final user) async => <String>[],
  );

  Future<void> save() async => _executeForUser<void>(
    operation: 'save',
    action: (final user) async {},
    onFailureFallback: () async {},
  );
}
