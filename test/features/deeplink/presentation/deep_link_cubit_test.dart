import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_config.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_cubit.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDeepLinkService implements DeepLinkService {
  _FakeDeepLinkService({this.initial});

  final Uri? initial;
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  @override
  Stream<Uri> linkStream() => _controller.stream;

  @override
  Future<Uri?> getInitialLink() async => initial;

  void add(Uri uri) => _controller.add(uri);

  Future<void> close() => _controller.close();
}

void main() {
  late _FakeDeepLinkService service;
  const DeepLinkParser parser = DeepLinkParser();

  tearDown(() async {
    await service.close();
  });

  group('DeepLinkCubit', () {
    final Uri counterUri = Uri.parse(
      '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}',
    );
    final Uri chatUri = Uri.parse(
      '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}/chat',
    );

    blocTest<DeepLinkCubit, DeepLinkState>(
      'emits navigation for initial link',
      build: () {
        service = _FakeDeepLinkService(initial: chatUri);
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => <DeepLinkState>[
        const DeepLinkNavigate(DeepLinkTarget.chat, DeepLinkOrigin.initial),
        const DeepLinkIdle(),
      ],
    );

    blocTest<DeepLinkCubit, DeepLinkState>(
      'emits navigation for subsequent links',
      build: () {
        service = _FakeDeepLinkService(initial: null);
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) async {
        await cubit.initialize();
        service.add(counterUri);
      },
      expect: () => <DeepLinkState>[
        const DeepLinkNavigate(DeepLinkTarget.counter, DeepLinkOrigin.resumed),
        const DeepLinkIdle(),
      ],
    );

    blocTest<DeepLinkCubit, DeepLinkState>(
      'ignores unsupported links',
      build: () {
        service = _FakeDeepLinkService(initial: null);
        return DeepLinkCubit(service: service, parser: parser);
      },
      act: (cubit) async {
        await cubit.initialize();
        service.add(
          Uri.parse(
            '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}/unknown',
          ),
        );
      },
      expect: () => <DeepLinkState>[],
    );
  });
}
