/// Generator for exhaustive switch helpers on sealed state classes
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../../../../lib/shared/annotations/bloc_annotations.dart';

/// Generates exhaustive switch helpers for sealed state classes
class SealedStateSwitchGenerator
    extends GeneratorForAnnotation<GenerateSwitchHelper> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'GenerateSwitchHelper can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name;
    final library = element.library;
    if (library == null) {
      throw InvalidGenerationSourceError(
        'Cannot determine library for $className',
        element: element,
      );
    }

    // Find all subclasses of this sealed class
    final subclasses = _findSubclasses(element, library);

    if (subclasses.isEmpty) {
      throw InvalidGenerationSourceError(
        'No subclasses found for sealed class $className',
        element: element,
      );
    }

    // Generate when() method with exhaustive switch
    final buffer = StringBuffer();
    buffer.writeln('// Generated code for $className');
    buffer.writeln('extension ${className}SwitchHelper on $className {');
    buffer.writeln('  /// Exhaustive pattern matching helper');
    buffer.writeln('  T when<T>({');

    // Generate parameters for each subclass
    for (final subclass in subclasses) {
      final params = _extractConstructorParams(subclass);
      if (params.isEmpty) {
        buffer.writeln(
          '    required T Function() ${_toCamelCase(subclass.name)},',
        );
      } else {
        final paramList = params.map((p) => '${p.type} ${p.name}').join(', ');
        buffer.writeln(
          '    required T Function($paramList) ${_toCamelCase(subclass.name)},',
        );
      }
    }

    buffer.writeln('  }) {');
    buffer.writeln('    return switch (this) {');

    // Generate switch cases
    for (final subclass in subclasses) {
      final params = _extractConstructorParams(subclass);
      if (params.isEmpty) {
        buffer.writeln(
          '      ${subclass.name}() => ${_toCamelCase(subclass.name)}(),',
        );
      } else {
        final paramBindings = params.map((p) => ':final ${p.name}').join(', ');
        buffer.writeln(
          '      ${subclass.name}($paramBindings) => ${_toCamelCase(subclass.name)}(${params.map((p) => p.name).join(', ')}),',
        );
      }
    }

    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  List<ClassElement> _findSubclasses(
    ClassElement sealedClass,
    LibraryElement library,
  ) {
    final subclasses = <ClassElement>[];
    for (final element in library.topLevelElements) {
      if (element is ClassElement &&
          element.supertype?.element == sealedClass) {
        subclasses.add(element);
      }
    }
    return subclasses;
  }

  List<_Param> _extractConstructorParams(ClassElement classElement) {
    final params = <_Param>[];
    final constructors = classElement.constructors;
    if (constructors.isEmpty) {
      return params;
    }

    // Use the first public constructor
    final constructor = constructors.firstWhere(
      (c) => !c.isPrivate,
      orElse: () => constructors.first,
    );

    for (final param in constructor.parameters) {
      if (param.isNamed || param.isOptionalPositional) {
        continue; // Skip optional parameters for now
      }
      params.add(
        _Param(
          name: param.name,
          type: param.type.getDisplayString(withNullability: true),
        ),
      );
    }

    return params;
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toLowerCase() + input.substring(1);
  }
}

class _Param {
  _Param({required this.name, required this.type});
  final String name;
  final String type;
}
