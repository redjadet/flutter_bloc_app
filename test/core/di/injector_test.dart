import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/deeplink/data/app_links_deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/hive_locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/hive_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() {
  final GetIt injector = getIt;

  setUpAll(() async {
    // Initialize Hive for testing
    final Directory testDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(testDir.path);
  });

  setUp(() async {
    await injector.reset(dispose: true);
  });

  test('configureDependencies registers shared services', () async {
    await configureDependencies();

    final CounterRepository counterRepository = injector<CounterRepository>();
    expect(counterRepository, isA<HiveCounterRepository>());

    final http.Client client = injector<http.Client>();
    expect(client, isA<http.Client>());

    final GraphqlDemoRepository graphqlRepository =
        injector<GraphqlDemoRepository>();
    expect(graphqlRepository, isA<CountriesGraphqlRepository>());

    final ChatRepository chatRepository = injector<ChatRepository>();
    expect(chatRepository, isA<HuggingfaceChatRepository>());

    final ChatHistoryRepository historyRepository =
        injector<ChatHistoryRepository>();
    expect(historyRepository, isNotNull);

    final LocaleRepository localeRepository = injector<LocaleRepository>();
    expect(localeRepository, isA<HiveLocaleRepository>());

    final ThemeRepository themeRepository = injector<ThemeRepository>();
    expect(themeRepository, isA<HiveThemeRepository>());

    final DeepLinkParser parser = injector<DeepLinkParser>();
    expect(parser, isA<DeepLinkParser>());

    final DeepLinkService service = injector<DeepLinkService>();
    expect(service, isA<AppLinksDeepLinkService>());
  });

  test('ensureConfigured can be called after configureDependencies', () async {
    await configureDependencies();
    ensureConfigured();
    await Future<void>.delayed(Duration.zero);

    expect(injector.isRegistered<ChatRepository>(), isTrue);
    expect(injector<HuggingFaceResponseParser>(), isNotNull);
  });
}
