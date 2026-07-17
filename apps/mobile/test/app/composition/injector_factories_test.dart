import 'package:flutter_bloc_app/app/composition/injector_factories.dart';
import 'package:flutter_bloc_app/features/remote_config/data/fake_remote_config_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('injector_factories', () {
    test(
      'createRemoteConfigRemoteDataSource returns fake when Firebase absent',
      () {
        final dataSource = createRemoteConfigRemoteDataSource();
        expect(dataSource, isA<FakeRemoteConfigRemoteDataSource>());
      },
    );
  });
}
