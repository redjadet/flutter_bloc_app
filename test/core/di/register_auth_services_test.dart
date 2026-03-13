import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart' as core_auth;
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/register_auth_services.dart';
import 'package:flutter_bloc_app/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart'
    as feature_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('registerAuthServices', () {
    test(
      'registers the core auth contract as the same singleton as feature auth',
      () {
        getIt.registerSingleton<FirebaseAuth>(_MockFirebaseAuth());

        registerAuthServices();

        final feature_auth.AuthRepository featureRepository =
            getIt<feature_auth.AuthRepository>();
        final core_auth.AuthRepository coreRepository =
            getIt<core_auth.AuthRepository>();

        expect(featureRepository, isA<FirebaseAuthRepository>());
        expect(identical(coreRepository, featureRepository), isTrue);
      },
    );
  });
}
