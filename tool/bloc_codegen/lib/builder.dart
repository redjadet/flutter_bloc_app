/// build_runner entry points for [bloc_codegen] generators.
library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/sealed_state_switch_generator.dart';
import 'src/state_validator_generator.dart';

/// Builder for `@GenerateSwitchHelper`.
Builder sealedStateSwitchGenerator(BuilderOptions options) => SharedPartBuilder(
  [const SealedStateSwitchGenerator()],
  'sealed_state_switch',
);

/// Builder for `@GenerateStateValidator`.
Builder stateValidatorGenerator(BuilderOptions options) =>
    SharedPartBuilder([const StateValidatorGenerator()], 'state_validator');
