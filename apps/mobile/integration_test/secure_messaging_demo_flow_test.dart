import 'flow_scenarios.dart';
import 'test_harness.dart';

/// Real Flutter → Rust round trip. Run on macOS (supported product desktop).
///
/// ```bash
/// cd apps/mobile
/// flutter test integration_test/secure_messaging_demo_flow_test.dart -d macos
/// ```
void main() {
  registerIntegrationHarness();
  registerSecureMessagingDemoIntegrationFlow();
}
