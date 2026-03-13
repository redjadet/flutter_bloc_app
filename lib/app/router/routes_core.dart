import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/deferred_pages/chart_page.dart'
    deferred as chart_page;
import 'package:flutter_bloc_app/app/router/deferred_pages/markdown_editor_page.dart'
    deferred as markdown_editor_page;
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/logged_out_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/profile_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_bloc_app/features/calculator/calculator.dart';
import 'package:flutter_bloc_app/features/camera_gallery/camera_gallery.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/example_page.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/whiteboard_page.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/pages/graphql_demo_page.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/pages/library_demo_page.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_bloc_app/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/scapes.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/deferred_page.dart';
import 'package:go_router/go_router.dart';

/// Core app routes: auth, counter, calculator, example, settings, profile, etc.
List<GoRoute> createCoreRoutes() => <GoRoute>[
  GoRoute(
    path: AppRoutes.authPath,
    name: AppRoutes.auth,
    builder: (final context, final state) => SignInPage(
      redirectAfterLogin: state.uri.queryParameters['redirect'],
    ),
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
            timerService: getIt<TimerService>(),
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
    path: AppRoutes.cameraGalleryPath,
    name: AppRoutes.cameraGallery,
    builder: (final context, final state) => BlocProvider<CameraGalleryCubit>(
      create: (_) => CameraGalleryCubit(
        repository: getIt<CameraGalleryRepository>(),
      ),
      child: const CameraGalleryPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.scapesPath,
    name: AppRoutes.scapes,
    builder: (final context, final state) => ScapesPage(
      repository: getIt<ScapesRepository>(),
      timerService: getIt<TimerService>(),
    ),
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
    builder: (final context, final state) => AppRouteAuthGate(
      policy: AppRoutePolicies.profile,
      getCurrentUser: () => getIt<AuthRepository>().currentUser,
      authStateChanges: getIt<AuthRepository>().authStateChanges,
      authPath: AppRoutes.authPath,
      child: BlocProviderHelpers.withAsyncInit<ProfileCubit>(
        create: () => ProfileCubit(
          repository: getIt<ProfileRepository>(),
        ),
        init: (final cubit) => cubit.loadProfile(),
        child: const ProfilePage(),
      ),
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
    builder: (final context, final state) => LibraryDemoPage(
      scapesRepository: getIt<ScapesRepository>(),
      timerService: getIt<TimerService>(),
    ),
  ),
];
