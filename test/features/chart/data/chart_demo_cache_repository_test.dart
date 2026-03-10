import 'dart:io';

import 'package:flutter_bloc_app/features/chart/data/chart_demo_cache_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late HiveService hiveService;
  late ChartDemoCacheRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('chart_cache_test_');
    Hive.init(tempDir.path);
    hiveService = HiveService(
      keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
    );
    await hiveService.initialize();
    repository = ChartDemoCacheRepository(hiveService: hiveService);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('persists and retrieves trending points', () async {
    final List<ChartPoint> points = <ChartPoint>[
      ChartPoint(date: DateTime.utc(2025, 3, 10), value: 50000.0),
      ChartPoint(date: DateTime.utc(2025, 3, 11), value: 51000.0),
    ];

    await repository.writeTrendingCounts(points);
    final List<ChartPoint> result = await repository.readTrendingCounts();

    expect(result.length, 2);
    expect(result[0].date, points[0].date);
    expect(result[0].value, points[0].value);
    expect(result[1].date, points[1].date);
    expect(result[1].value, points[1].value);
  });

  test('returns empty when cache is stale', () async {
    final List<ChartPoint> points = <ChartPoint>[
      ChartPoint(date: DateTime.utc(2025, 3, 10), value: 50000.0),
    ];

    await repository.writeTrendingCounts(points);
    final List<ChartPoint> stale = await repository.readTrendingCounts(
      maxAge: Duration.zero,
    );

    expect(stale, isEmpty);
  });

  test('skips invalid cached rows and keeps valid points', () async {
    final box = await repository.getBox();
    await box.put('trending_points', <String, dynamic>{
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'date': DateTime.utc(2025, 3, 10).toIso8601String(),
          'value': 50000.0,
        },
        <String, dynamic>{'date': 'not-a-date', 'value': 51000.0},
      ],
    });

    final List<ChartPoint> result = await repository.readTrendingCounts();

    expect(result, hasLength(1));
    expect(result.single.date, DateTime.utc(2025, 3, 10));
    expect(result.single.value, 50000.0);
  });
}
