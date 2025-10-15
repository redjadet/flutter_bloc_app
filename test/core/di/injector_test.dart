import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/shared_preferences_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/deeplink/data/uni_links_deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/countries_graphql_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/shared_preferences_locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/shared_preferences_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';

void main() {
  final GetIt injector = getIt;

  setUp(() async {
    await injector.reset(dispose: true);
  });

  test('configureDependencies registers shared services', () async {
    await configureDependencies();

    final CounterRepository counterRepository = injector<CounterRepository>();
    expect(counterRepository, isA<SharedPreferencesCounterRepository>());

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
    expect(localeRepository, isA<SharedPreferencesLocaleRepository>());

    final ThemeRepository themeRepository = injector<ThemeRepository>();
    expect(themeRepository, isA<SharedPreferencesThemeRepository>());

    final DeepLinkParser parser = injector<DeepLinkParser>();
    expect(parser, isA<DeepLinkParser>());

    final DeepLinkService service = injector<DeepLinkService>();
    expect(service, isA<UniLinksDeepLinkService>());
  });

  test('ensureConfigured can be called after configureDependencies', () async {
    await configureDependencies();
    ensureConfigured();
    await Future<void>.delayed(Duration.zero);

    expect(injector.isRegistered<ChatRepository>(), isTrue);
    expect(injector<HuggingFaceResponseParser>(), isNotNull);
  });
}
