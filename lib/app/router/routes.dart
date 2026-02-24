import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/router/deferred_pages/chart_page.dart'
    deferred as chart_page;
import 'package:flutter_bloc_app/app/router/deferred_pages/markdown_editor_page.dart'
    deferred as markdown_editor_page;
import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/logged_out_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/profile_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_bloc_app/features/calculator/calculator.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/example_page.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/whiteboard_page.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/pages/genui_demo_page.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/pages/graphql_demo_page.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/pages/library_demo_page.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/playlearn_page.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/vocabulary_list_page.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_bloc_app/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_bloc_app/features/scapes/scapes.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/deferred_page.dart';
import 'package:go_router/go_router.dart';

/// Creates the list of application routes with async init where needed.
List<GoRoute> createAppRoutes() => <GoRoute>[
  GoRoute(
    path: AppRoutes.authPath,
    name: AppRoutes.auth,
    builder: (final context, final state) => const SignInPage(),
  ),
  GoRoute(
    path: AppRoutes.counterPath,
    name: AppRoutes.counter,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<CounterCubit>(
          create: () => CounterCubit(
            repository: getIt<CounterRepository>(),
            timerService: getIt<TimerService>(),
            loadDelay: getIt<AppRuntimeConfig>().skeletonDelay,
          ),
          init: (final cubit) => cubit.loadInitial(),
          child: CounterPage(
            title: context.l10n.homeTitle,
            errorNotificationService: getIt<ErrorNotificationService>(),
            biometricAuthenticator: getIt<BiometricAuthenticator>(),
          ),
        ),
  ),
  GoRoute(
    path: AppRoutes.calculatorPath,
    name: AppRoutes.calculator,
    builder: (final context, final state) => BlocProvider(
      create: (_) => CalculatorCubit(
        calculator: getIt<PaymentCalculator>(),
      ),
      child: const CalculatorPage(),
    ),
    routes: [
      GoRoute(
        path: 'payment',
        name: AppRoutes.calculatorPayment,
        builder: (final context, final state) {
          final Object? extra = state.extra;
          if (extra is CalculatorCubit) {
            return BlocProvider.value(
              value: extra,
              child: const CalculatorPaymentPage(),
            );
          }
          return BlocProvider(
            create: (_) => CalculatorCubit(
              calculator: getIt<PaymentCalculator>(),
            ),
            child: const CalculatorPaymentPage(),
          );
        },
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.examplePath,
    name: AppRoutes.example,
    builder: (final context, final state) => const ExamplePage(),
  ),
  GoRoute(
    path: AppRoutes.whiteboardPath,
    name: AppRoutes.whiteboard,
    builder: (final context, final state) => const WhiteboardPage(),
  ),
  GoRoute(
    path: AppRoutes.scapesPath,
    name: AppRoutes.scapes,
    builder: (final context, final state) => const ScapesPage(),
  ),
  GoRoute(
    path: AppRoutes.markdownEditorPath,
    name: AppRoutes.markdownEditor,
    builder: (final context, final state) => DeferredPage(
      loadLibrary: markdown_editor_page.loadLibrary,
      builder: (final context) =>
          markdown_editor_page.buildMarkdownEditorPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.graphqlPath,
    name: AppRoutes.graphql,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<GraphqlDemoCubit>(
          create: () => GraphqlDemoCubit(
            repository: getIt<GraphqlDemoRepository>(),
          ),
          init: (final cubit) => cubit.loadInitial(),
          child: const GraphqlDemoPage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.chartsPath,
    name: AppRoutes.charts,
    builder: (final context, final state) => DeferredPage(
      loadLibrary: chart_page.loadLibrary,
      builder: (final context) => chart_page.buildChartPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.settingsPath,
    name: AppRoutes.settings,
    builder: (final context, final state) => SettingsPage(
      appInfoRepository: getIt<AppInfoRepository>(),
      graphqlCacheRepository: getIt<GraphqlCacheRepository>(),
      profileCacheRepository: getIt<ProfileCacheRepository>(),
    ),
  ),
  GoRoute(
    path: AppRoutes.manageAccountPath,
    name: AppRoutes.manageAccount,
    builder: (final context, final state) => const AuthProfilePage(),
  ),
  GoRoute(
    path: AppRoutes.profilePath,
    name: AppRoutes.profile,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<ProfileCubit>(
          create: () => ProfileCubit(
            repository: getIt<ProfileRepository>(),
          ),
          init: (final cubit) => cubit.loadProfile(),
          child: const ProfilePage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.registerPath,
    name: AppRoutes.register,
    builder: (final context, final state) => const RegisterPage(),
  ),
  GoRoute(
    path: AppRoutes.loggedOutPath,
    name: AppRoutes.loggedOut,
    builder: (final context, final state) => const LoggedOutPage(),
  ),
  GoRoute(
    path: AppRoutes.libraryDemoPath,
    name: AppRoutes.libraryDemo,
    builder: (final context, final state) => const LibraryDemoPage(),
  ),
  GoRoute(
    path: AppRoutes.chatPath,
    name: AppRoutes.chat,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<ChatCubit>(
          create: () => ChatCubit(
            repository: getIt<ChatRepository>(),
            historyRepository: getIt<ChatHistoryRepository>(),
            initialModel: SecretConfig.huggingfaceModel,
          ),
          init: (final cubit) => cubit.loadHistory(),
          child: ChatPage(
            errorNotificationService: getIt<ErrorNotificationService>(),
            pendingSyncRepository: getIt<PendingSyncRepository>(),
          ),
        ),
  ),
  GoRoute(
    path: AppRoutes.chatListPath,
    name: AppRoutes.chatList,
    builder: (final context, final state) => ChatListPage(
      repository: getIt<ChatListRepository>(),
      chatRepository: getIt<ChatRepository>(),
      historyRepository: getIt<ChatHistoryRepository>(),
      errorNotificationService: getIt<ErrorNotificationService>(),
      pendingSyncRepository: getIt<PendingSyncRepository>(),
    ),
  ),
  GoRoute(
    path: AppRoutes.genuiDemoPath,
    name: AppRoutes.genuiDemo,
    builder: (final context, final state) {
      final apiKey = SecretConfig.geminiApiKey;
      if (apiKey == null || apiKey.isEmpty) {
        return CommonPageLayout(
          title: context.l10n.genuiDemoPageTitle,
          body: CommonErrorView(
            message: context.l10n.genuiDemoNoApiKey,
          ),
        );
      }
      return BlocProviderHelpers.withAsyncInit<GenUiDemoCubit>(
        create: () => GenUiDemoCubit(agent: getIt<GenUiDemoAgent>()),
        init: (final cubit) => cubit.initialize(),
        child: const GenUiDemoPage(),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.playlearnPath,
    name: AppRoutes.playlearn,
    builder: (final context, final state) => const PlaylearnPage(),
    routes: <GoRoute>[
      GoRoute(
        path: 'vocabulary/:topicId',
        name: AppRoutes.playlearnVocabulary,
        builder: (final context, final state) {
          final topicId = state.pathParameters['topicId'] ?? '';
          return VocabularyListPage(topicId: topicId);
        },
      ),
    ],
  ),
  ...createAuxiliaryRoutes(),
];
