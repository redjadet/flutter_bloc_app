/// Generator for state transition validators.
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotations/bloc_annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Generates state transition validators from annotations.
class StateValidatorGenerator
    extends GeneratorForAnnotation<GenerateStateValidator> {
  /// Creates a generator that matches annotations from `bloc_annotations`.
  const StateValidatorGenerator() : super(inPackage: 'bloc_annotations');

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
    if (className == null) {
      throw InvalidGenerationSourceError(
        'Annotated class must have a name.',
        element: element,
      );
    }

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
      'class ${className}TransitionValidator '
      'extends StateTransitionValidator<$className> {',
    );
    buffer.writeln('  @override');
    buffer.writeln(
      '  bool isValidTransition($className from, $className to) {',
    );
    buffer.writeln('    return switch ((from, to)) {');

    for (final transition in transitions) {
      final reader = ConstantReader(transition);
      final from = reader.read('from').stringValue;
      final to = reader.read('to').stringValue;
      buffer.writeln('      ($from, $to) => true,');
    }

    buffer.writeln('      _ => false,');
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }
}
