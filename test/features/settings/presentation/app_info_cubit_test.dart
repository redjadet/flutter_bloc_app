import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/app_info_cubit.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppInfoCubit', () {
    blocTest<AppInfoCubit, AppInfoState>(
      'emits success when repository resolves',
      build: () =>
          AppInfoCubit(repository: const _FakeSuccessAppInfoRepository()),
      act: (cubit) => cubit.load(),
      expect: () => const <AppInfoState>[
        AppInfoState(status: ViewStatus.loading),
        AppInfoState(
          status: ViewStatus.success,
          info: AppInfo(version: '2.0.0', buildNumber: '20'),
        ),
      ],
    );

    blocTest<AppInfoCubit, AppInfoState>(
      'emits failure when repository throws',
      build: () =>
          AppInfoCubit(repository: const _FakeErrorAppInfoRepository()),
      act: (cubit) => cubit.load(),
      expect: () => <Matcher>[
        equals(const AppInfoState(status: ViewStatus.loading)),
        isA<AppInfoState>()
            .having((state) => state.status, 'status', ViewStatus.error)
            .having(
              (state) => state.errorMessage,
              'errorMessage',
              contains('load-error'),
            ),
      ],
    );

    blocTest<AppInfoCubit, AppInfoState>(
      'does not duplicate loads while already loading',
      build: () => AppInfoCubit(repository: const _DelayedAppInfoRepository()),
      act: (cubit) async {
        unawaited(cubit.load());
        await cubit.load();
      },
      wait: const Duration(milliseconds: 250),
      expect: () => const <AppInfoState>[
        AppInfoState(status: ViewStatus.loading),
        AppInfoState(
          status: ViewStatus.success,
          info: AppInfo(version: '3.0.0', buildNumber: '300'),
        ),
      ],
    );
  });
}

class _FakeSuccessAppInfoRepository implements AppInfoRepository {
  const _FakeSuccessAppInfoRepository();

  @override
  Future<AppInfo> load() async =>
      const AppInfo(version: '2.0.0', buildNumber: '20');
}

class _FakeErrorAppInfoRepository implements AppInfoRepository {
  const _FakeErrorAppInfoRepository();

  @override
  Future<AppInfo> load() async {
    throw StateError('load-error');
  }
}

class _DelayedAppInfoRepository implements AppInfoRepository {
  const _DelayedAppInfoRepository();

  @override
  Future<AppInfo> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const AppInfo(version: '3.0.0', buildNumber: '300');
  }
}
