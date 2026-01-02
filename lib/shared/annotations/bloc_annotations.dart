/// Annotations for BLoC/Cubit code generation
library;

/// Annotation to generate exhaustive switch helpers for sealed state classes
class GenerateSwitchHelper {
  const GenerateSwitchHelper();
}

/// Annotation to generate state transition validators
class GenerateStateValidator {
  const GenerateStateValidator({
    this.transitions = const [],
  });

  final List<StateTransition> transitions;
}

/// Defines a valid state transition
class StateTransition {
  const StateTransition({
    required this.from,
    required this.to,
  });

  final String from;
  final String to;
}

/// Annotation to generate type-safe cubit factory
class GenerateCubitFactory {
  const GenerateCubitFactory();
}
