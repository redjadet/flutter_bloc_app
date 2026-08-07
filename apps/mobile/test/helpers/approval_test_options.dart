import 'package:approval_tests/approval_tests.dart';

/// Shared [Options] for mobile unit approvals.
///
/// Strict missing-approved policy keeps CI from inventing baselines. Bootstrap
/// locally with `MissingApprovedPolicy.createAndPass` / `approveResult: true`,
/// review the `*.approved.*` artifact, then keep this helper in strict mode.
Options approvalTestOptions({
  final ApprovalNamer namer = const Namer(),
  final bool approveResult = false,
  final MissingApprovedPolicy missingApprovedPolicy =
      MissingApprovedPolicy.writeReceivedAndFail,
}) => Options(
  reporter: const CommandLineReporter(),
  missingApprovedPolicy: missingApprovedPolicy,
  namer: namer,
  approveResult: approveResult,
  includeClassNameDuringSerialization: false,
);
