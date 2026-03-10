import 'package:flutter_bloc_app/features/graphql_demo/data/auth_aware_graphql_remote_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_remote_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements GraphqlRemoteRepository {}

void main() {
  group('AuthAwareGraphqlRemoteRepository', () {
    late _MockRemote supabase;
    late _MockRemote direct;
    late bool signedIn;
    late AuthAwareGraphqlRemoteRepository repo;

    setUp(() {
      supabase = _MockRemote();
      direct = _MockRemote();
      signedIn = false;
      repo = AuthAwareGraphqlRemoteRepository(
        supabaseRemote: supabase,
        directRemote: direct,
        isSupabaseSignedIn: () => signedIn,
      );
    });

    test('delegates to direct remote when not signed in', () async {
      when(() => direct.lastSource).thenReturn(GraphqlDataSource.remote);
      when(
        () => direct.fetchContinents(),
      ).thenAnswer((_) async => const <GraphqlContinent>[]);

      expect(repo.lastSource, GraphqlDataSource.unknown);
      await repo.fetchContinents();
      expect(repo.lastSource, GraphqlDataSource.remote);

      verify(() => direct.fetchContinents()).called(1);
      verifyNever(() => supabase.fetchContinents());
    });

    test('delegates to supabase remote when signed in', () async {
      signedIn = true;
      when(
        () => supabase.lastSource,
      ).thenReturn(GraphqlDataSource.supabaseTables);
      when(
        () =>
            supabase.fetchCountries(continentCode: any(named: 'continentCode')),
      ).thenAnswer((_) async => const <GraphqlCountry>[]);

      expect(repo.lastSource, GraphqlDataSource.unknown);
      await repo.fetchCountries(continentCode: 'EU');
      expect(repo.lastSource, GraphqlDataSource.supabaseTables);

      verify(() => supabase.fetchCountries(continentCode: 'EU')).called(1);
      verifyNever(
        () => direct.fetchCountries(continentCode: any(named: 'continentCode')),
      );
    });

    test('switches delegate dynamically across calls', () async {
      when(() => direct.lastSource).thenReturn(GraphqlDataSource.remote);
      when(
        () => supabase.lastSource,
      ).thenReturn(GraphqlDataSource.supabaseTables);
      when(
        () => direct.fetchContinents(),
      ).thenAnswer((_) async => const <GraphqlContinent>[]);
      when(
        () => supabase.fetchContinents(),
      ).thenAnswer((_) async => const <GraphqlContinent>[]);

      signedIn = false;
      await repo.fetchContinents();
      signedIn = true;
      await repo.fetchContinents();

      verify(() => direct.fetchContinents()).called(1);
      verify(() => supabase.fetchContinents()).called(1);
    });

    test(
      'lastSource reflects the delegate that served the last request',
      () async {
        when(() => direct.lastSource).thenReturn(GraphqlDataSource.remote);
        when(
          () => supabase.lastSource,
        ).thenReturn(GraphqlDataSource.supabaseTables);
        when(() => direct.fetchContinents()).thenAnswer((_) async {
          signedIn = true;
          return const <GraphqlContinent>[];
        });

        await repo.fetchContinents();

        expect(repo.lastSource, GraphqlDataSource.remote);
      },
    );
  });
}
