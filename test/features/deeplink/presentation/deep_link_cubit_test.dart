import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_cubit.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDeepLinkService extends Mock implements DeepLinkService {}

class _MockDeepLinkParser extends Mock implements DeepLinkParser {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://fallback.test'));
  });

  group('DeepLinkCubit', () {
    late _MockDeepLinkService service;
    late _MockDeepLinkParser parser;
    late StreamController<Uri> streamController;

    setUp(() {
      service = _MockDeepLinkService();
      parser = _MockDeepLinkParser();
      streamController = StreamController<Uri>.broadcast();

      when(
        () => service.linkStream(),
      ).thenAnswer((_) => streamController.stream);
      when(() => parser.parse(any())).thenReturn(DeepLinkTarget.counter);
    });

    tearDown(() async {
      await streamController.close();
    });

    blocTest<DeepLinkCubit, DeepLinkState>(
      'emits loading then idle when initialization succeeds with no initial link',
      build: () {
        when(service.getInitialLink).thenAnswer((_) async => null);
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const <DeepLinkState>[DeepLinkLoading(), DeepLinkIdle()],
      verify: (_) {
        verify(service.getInitialLink).called(1);
        verify(() => service.linkStream()).called(1);
      },
    );

    blocTest<DeepLinkCubit, DeepLinkState>(
      'emits navigation when initial link is present',
      build: () {
        final Uri initialUri = Uri.parse(
          'https://links.flutterbloc.app/charts',
        );
        when(service.getInitialLink).thenAnswer((_) async => initialUri);
        when(() => parser.parse(initialUri)).thenReturn(DeepLinkTarget.charts);
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const <DeepLinkState>[
        DeepLinkLoading(),
        DeepLinkNavigate(DeepLinkTarget.charts, DeepLinkOrigin.initial),
        DeepLinkIdle(),
      ],
    );

    blocTest<DeepLinkCubit, DeepLinkState>(
      'emits error when getInitialLink throws then recovers on retry',
      build: () {
        when(service.getInitialLink).thenThrow(Exception('init failed'));
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) async {
        await cubit.initialize();
        when(service.getInitialLink).thenAnswer((_) async => null);
        await cubit.retryInitialize();
      },
      expect: () => const <DeepLinkState>[
        DeepLinkLoading(),
        DeepLinkError('Exception: init failed'),
        DeepLinkLoading(),
        DeepLinkIdle(),
      ],
      verify: (_) {
        verify(service.getInitialLink).called(2);
      },
    );

    late Completer<Uri?> pendingInitialLink;

    blocTest<DeepLinkCubit, DeepLinkState>(
      'ignores overlapping initialize calls',
      build: () {
        pendingInitialLink = Completer<Uri?>();
        when(
          service.getInitialLink,
        ).thenAnswer((_) => pendingInitialLink.future);
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) async {
        final Future<void> first = cubit.initialize();
        await cubit.initialize();
        when(service.getInitialLink).thenAnswer((_) async => null);
        streamController.addStream(Stream<Uri>.empty());
        pendingInitialLink.complete(null);
        await first;
      },
      expect: () => const <DeepLinkState>[DeepLinkLoading(), DeepLinkIdle()],
      verify: (_) {
        verify(service.getInitialLink).called(1);
      },
    );

    blocTest<DeepLinkCubit, DeepLinkState>(
      'emits error when stream emits error',
      build: () {
        when(service.getInitialLink).thenAnswer((_) async => null);
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) async {
        await cubit.initialize();
        streamController.addError(Exception('stream error'));
      },
      expect: () => const <DeepLinkState>[
        DeepLinkLoading(),
        DeepLinkIdle(),
        DeepLinkError('Exception: stream error'),
      ],
    );

    blocTest<DeepLinkCubit, DeepLinkState>(
      'recovers via retryInitialize after stream error',
      build: () {
        when(service.getInitialLink).thenAnswer((_) async => null);
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) async {
        await cubit.initialize();
        streamController.addError(Exception('stream error'));
        await Future<void>.delayed(Duration.zero);
        when(service.getInitialLink).thenAnswer((_) async => null);
        await cubit.retryInitialize();
      },
      expect: () => const <DeepLinkState>[
        DeepLinkLoading(),
        DeepLinkIdle(),
        DeepLinkError('Exception: stream error'),
        DeepLinkLoading(),
        DeepLinkIdle(),
      ],
      verify: (_) {
        verify(service.getInitialLink).called(2);
        verify(() => service.linkStream()).called(2);
      },
    );
  });
}
