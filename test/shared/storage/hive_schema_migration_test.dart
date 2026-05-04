import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/storage/hive_schema_migration.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart' as test_helpers;

void main() {
  group('Hive schema migration (MVP-0)', () {
    late HiveService hiveService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await test_helpers.setupHiveForTesting();
    });

    tearDown(() {
      HiveSchemaMigratorService.enabledOverrideForTest = null;
    });

    setUp(() async {
      hiveService = await test_helpers.createHiveService();
    });

    tearDown(() async {
      await test_helpers.cleanupHiveBoxes(['schema_box']);
    });

    test('writes fingerprint metadata on first adoption', () async {
      final _SchemaRepo repo = _SchemaRepo(
        hiveService: hiveService,
        fingerprint: 'fp_v1',
      );
      final box = await repo.getBox();

      final dynamic raw = box.get(
        HiveSchemaMigratorService.metaKeyFingerprints,
      );
      expect(raw, isA<Map>());
      expect((raw as Map)['ns'], 'fp_v1');
    });

    test('does not overwrite fingerprint on mismatch in MVP-0', () async {
      final _SchemaRepo repoV1 = _SchemaRepo(
        hiveService: hiveService,
        fingerprint: 'fp_v1',
      );
      final box = await repoV1.getBox();

      // Simulate later schema version.
      final _SchemaRepo repoV2 = _SchemaRepo(
        hiveService: hiveService,
        fingerprint: 'fp_v2',
      );
      await repoV2.getBox();

      final dynamic raw = box.get(
        HiveSchemaMigratorService.metaKeyFingerprints,
      );
      expect(raw, isA<Map>());
      expect((raw as Map)['ns'], 'fp_v1');
    });

    test('kill switch disables metadata writes', () async {
      HiveSchemaMigratorService.enabledOverrideForTest = false;
      final _SchemaRepo repo = _SchemaRepo(
        hiveService: hiveService,
        fingerprint: 'fp_v1',
      );
      final box = await repo.getBox();
      expect(box.get(HiveSchemaMigratorService.metaKeyFingerprints), isNull);
    });
  });
}

class _SchemaRepo extends HiveRepositoryBase {
  _SchemaRepo({required super.hiveService, required this.fingerprint});

  final String fingerprint;

  @override
  String get boxName => 'schema_box';

  @override
  HiveBoxSchema? get schema => HiveBoxSchema(
    boxName: boxName,
    namespace: 'ns',
    fingerprint: fingerprint,
  );
}
