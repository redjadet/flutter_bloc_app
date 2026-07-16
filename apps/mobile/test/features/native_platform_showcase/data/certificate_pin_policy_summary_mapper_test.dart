import 'package:flutter_bloc_app/features/native_platform_showcase/data/certificate_pin_policy_summary_mapper.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/certificate_pin_policy_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

void main() {
  group('CertificatePinPolicySummaryMapper', () {
    test('maps a disabled config to a zeroed summary', () {
      final CertificatePinPolicySummary summary =
          CertificatePinPolicySummaryMapper.fromConfig(
            CertificatePinningConfig.disabled(),
            canOpenMutableDemo: false,
          );

      expect(summary.modeName, CertificatePinningMode.disabled.name);
      expect(summary.configuredHostCount, 0);
      expect(summary.primaryPinCount, 0);
      expect(summary.canOpenMutableDemo, isFalse);
    });

    test('counts hosts and pins without inventing pin roles', () {
      final config = CertificatePinningConfig(
        mode: CertificatePinningMode.mockSuccess,
        allowedHosts: <String>{'api.example.com', 'cdn.example.com'},
        sha256PinsByHost: <String, Set<String>>{
          'api.example.com': <String>{
            'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
            'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
          },
          'cdn.example.com': <String>{
            'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
          },
        },
      );

      final CertificatePinPolicySummary summary =
          CertificatePinPolicySummaryMapper.fromConfig(
            config,
            canOpenMutableDemo: true,
          );

      expect(summary.modeName, CertificatePinningMode.mockSuccess.name);
      expect(summary.pinHashKindName, config.pinHashKind.name);
      expect(summary.configuredHostCount, 2);
      expect(summary.primaryPinCount, 3);
      expect(summary.backupPinCount, 0);
      expect(summary.canOpenMutableDemo, isTrue);
    });

    test('counts only configured pins when a host has none', () {
      final config = CertificatePinningConfig(
        mode: CertificatePinningMode.mockSuccess,
        allowedHosts: <String>{'api.example.com', 'no-pins.example.com'},
        sha256PinsByHost: <String, Set<String>>{
          'api.example.com': <String>{
            'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
          },
        },
      );

      final CertificatePinPolicySummary summary =
          CertificatePinPolicySummaryMapper.fromConfig(
            config,
            canOpenMutableDemo: false,
          );

      expect(summary.configuredHostCount, 2);
      expect(summary.primaryPinCount, 1);
      expect(summary.backupPinCount, 0);
    });

    test('never exposes raw pin material in the summary', () {
      final config = CertificatePinningConfig(
        mode: CertificatePinningMode.mockSuccess,
        allowedHosts: <String>{'api.example.com'},
        sha256PinsByHost: <String, Set<String>>{
          'api.example.com': <String>{
            'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
          },
        },
      );

      final CertificatePinPolicySummary summary =
          CertificatePinPolicySummaryMapper.fromConfig(
            config,
            canOpenMutableDemo: false,
          );

      expect(
        summary.toString(),
        isNot(contains('sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=')),
      );
    });
  });
}
