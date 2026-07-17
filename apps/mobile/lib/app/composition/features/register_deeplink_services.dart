import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/deeplink/data/app_links_deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';

/// Registers deep link parser and service.
void registerDeepLinkServices() {
  registerLazySingletonIfAbsent<DeepLinkParser>(() => const DeepLinkParser());
  registerLazySingletonIfAbsent<DeepLinkService>(AppLinksDeepLinkService.new);
}
