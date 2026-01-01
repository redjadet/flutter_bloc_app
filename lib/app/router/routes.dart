import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/features.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:go_router/go_router.dart';

/// Creates the list of application routes.
///
/// **Route Initialization:**
/// Routes that require async initialization use `BlocProviderHelpers.withAsyncInit`
/// to load data without blocking the widget tree. Examples:
/// - `/graphql`: Loads countries data
/// - `/profile`: Loads user profile
/// - `/chat`: Loads chat history
/// - `/google-maps`: Loads map locations
List<GoRoute> createAppRoutes() => <GoRoute>[
  GoRoute(
    path: AppRoutes.authPath,
    name: AppRoutes.auth,
    builder: (final context, final state) => const SignInPage(),
  ),
  GoRoute(
    path: AppRoutes.counterPath,
    name: AppRoutes.counter,
    builder: (final context, final state) => CounterPage(
      title: context.l10n.homeTitle,
      errorNotificationService: getIt<ErrorNotificationService>(),
      biometricAuthenticator: getIt<BiometricAuthenticator>(),
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
    path: AppRoutes.markdownEditorPath,
    name: AppRoutes.markdownEditor,
    builder: (final context, final state) => const MarkdownEditorPage(),
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
    builder: (final context, final state) => ChartPage(
      repository: getIt<ChartRepository>(),
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
    path: AppRoutes.websocketPath,
    name: AppRoutes.websocket,
    builder: (final context, final state) => BlocProvider(
      create: (_) => WebsocketCubit(repository: getIt<WebsocketRepository>()),
      child: const WebsocketDemoPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.googleMapsPath,
    name: AppRoutes.googleMaps,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<MapSampleCubit>(
          create: () => MapSampleCubit(
            repository: getIt<MapLocationRepository>(),
          ),
          init: (final cubit) => cubit.loadLocations(),
          child: const GoogleMapsSamplePage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.searchPath,
    name: AppRoutes.search,
    builder: (final context, final state) => SearchPage(
      repository: getIt<SearchRepository>(),
      timerService: getIt<TimerService>(),
    ),
  ),
];
