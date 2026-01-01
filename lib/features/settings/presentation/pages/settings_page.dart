import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.appInfoRepository,
    this.graphqlCacheRepository,
    this.profileCacheRepository,
    super.key,
  });

  final AppInfoRepository appInfoRepository;
  final GraphqlCacheRepository? graphqlCacheRepository;
  final ProfileCacheRepository? profileCacheRepository;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AppInfoCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AppInfoCubit(repository: widget.appInfoRepository);
    unawaited(_cubit.load());
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: _SettingsView(
      graphqlCacheRepository: widget.graphqlCacheRepository,
      profileCacheRepository: widget.profileCacheRepository,
    ),
  );
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({
    this.graphqlCacheRepository,
    this.profileCacheRepository,
  });

  final GraphqlCacheRepository? graphqlCacheRepository;
  final ProfileCacheRepository? profileCacheRepository;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final GraphqlCacheRepository? graphqlRepo = graphqlCacheRepository;
    final ProfileCacheRepository? cacheRepo = profileCacheRepository;
    final List<Widget> sections = <Widget>[
      const AccountSection(),
      SizedBox(height: context.responsiveGapL),
      const ThemeSection(),
      SizedBox(height: context.responsiveGapL),
      const LanguageSection(),
      SizedBox(height: context.responsiveGapL),
      const AppInfoSection(),
      if (FlavorManager.I.isDev || FlavorManager.I.isQa) ...[
        SizedBox(height: context.responsiveGapL),
        if (graphqlRepo != null)
          GraphqlCacheControlsSection(
            cacheRepository: graphqlRepo,
          ),
        SizedBox(height: context.responsiveGapL),
        if (cacheRepo != null)
          ProfileCacheControlsSection(
            profileCacheRepository: cacheRepo,
          ),
        SizedBox(height: context.responsiveGapL),
        const RemoteConfigDiagnosticsSection(),
        SizedBox(height: context.responsiveGapL),
        const SyncDiagnosticsSection(),
      ],
      if (!const bool.fromEnvironment('dart.vm.product')) ...[
        SizedBox(height: context.responsiveGapL),
        PlatformAdaptive.textButton(
          context: context,
          onPressed: () => throw Exception('Test exception for error handling'),
          child: const Text('Throw Test Exception'),
        ),
      ],
    ];
    return CommonPageLayout(
      title: l10n.settingsPageTitle,
      body: ListView.builder(
        key: const ValueKey('settings-list'),
        padding: EdgeInsets.zero,
        itemCount: sections.length,
        itemBuilder: (final BuildContext context, final int index) =>
            sections[index],
      ),
    );
  }
}
