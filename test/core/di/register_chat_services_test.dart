import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/data/composite_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/supabase_chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart' as test_helpers;

void main() {
  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    SecretConfig.resetForTest();
    SecretConfig.debugEnvironment = <String, dynamic>{
      'HUGGINGFACE_API_KEY': 'env-key',
      'HUGGINGFACE_MODEL': 'openai/gpt-oss-20b',
      'HUGGINGFACE_USE_CHAT_COMPLETIONS': false,
      'SUPABASE_URL': 'https://env.supabase.co',
      'SUPABASE_ANON_KEY': 'anon-env',
    };
    await getIt.reset(dispose: true);
  });

  tearDown(() {
    SecretConfig.resetForTest();
  });

  test('configureDependencies keeps router chat completions enabled even when'
      ' persisted config disables it', () async {
    await configureDependencies();

    final HuggingfaceChatRepository repository =
        getIt<HuggingfaceChatRepository>();

    expect(repository.usesChatCompletions, isTrue);
  });

  test(
    'configureDependencies registers Supabase and composite chat repos',
    () async {
      await configureDependencies();

      expect(getIt<SupabaseChatRepository>(), isNotNull);
      expect(getIt<CompositeChatRepository>(), isNotNull);
    },
  );
}
