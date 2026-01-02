/// Generator for state transition validators
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../../../../lib/shared/annotations/bloc_annotations.dart';

/// Generates state transition validators from annotations
class StateValidatorGenerator
    extends GeneratorForAnnotation<GenerateStateValidator> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'GenerateStateValidator can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name;
    final transitions = annotation.read('transitions').listValue;

    if (transitions.isEmpty) {
      throw InvalidGenerationSourceError(
        'GenerateStateValidator requires at least one transition',
        element: element,
      );
    }

    final buffer = StringBuffer();
    buffer.writeln('// Generated state transition validator for $className');
    buffer.writeln(
      'class ${className}TransitionValidator extends StateTransitionValidator<$className> {',
    );
    buffer.writeln('  @override');
    buffer.writeln(
      '  bool isValidTransition($className from, $className to) {',
    );
    buffer.writeln('    return switch ((from, to)) {');

    // Generate switch cases for each transition
    for (final transition in transitions) {
      final from = transition.read('from').stringValue;
      final to = transition.read('to').stringValue;
      buffer.writeln('      ($from, $to) => true,');
    }

    buffer.writeln('      _ => false,');
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }
}
