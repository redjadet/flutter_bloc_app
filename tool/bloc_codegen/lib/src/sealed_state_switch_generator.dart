/// Generator for exhaustive switch helpers on sealed state classes.
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotations/bloc_annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'naming.dart';

/// Generates exhaustive switch helpers for sealed state classes.
class SealedStateSwitchGenerator
    extends GeneratorForAnnotation<GenerateSwitchHelper> {
  /// Creates a generator that matches annotations from `bloc_annotations`.
  const SealedStateSwitchGenerator() : super(inPackage: 'bloc_annotations');

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
    if (className == null) {
      throw InvalidGenerationSourceError(
        'Annotated class must have a name.',
        element: element,
      );
    }

    final library = element.library;
    final subclasses = _findSubclasses(element, library);

    if (subclasses.isEmpty) {
      throw InvalidGenerationSourceError(
        'No subclasses found for sealed class $className',
        element: element,
      );
    }

    final buffer = StringBuffer();
    buffer.writeln('// Generated code for $className');
    buffer.writeln('extension ${className}SwitchHelper on $className {');
    buffer.writeln('  /// Exhaustive pattern matching helper');
    buffer.writeln('  T when<T>({');

    for (final subclass in subclasses) {
      final subclassName = subclass.name!;
      final params = _extractConstructorParams(subclass);
      if (params.isEmpty) {
        buffer.writeln(
          '    required T Function() ${toCamelCase(subclassName)},',
        );
      } else {
        final paramList = params.map((p) => '${p.type} ${p.name}').join(', ');
        buffer.writeln(
          '    required T Function($paramList) ${toCamelCase(subclassName)},',
        );
      }
    }

    buffer.writeln('  }) {');
    buffer.writeln('    return switch (this) {');

    for (final subclass in subclasses) {
      final subclassName = subclass.name!;
      final params = _extractConstructorParams(subclass);
      if (params.isEmpty) {
        buffer.writeln(
          '      $subclassName() => ${toCamelCase(subclassName)}(),',
        );
      } else {
        final paramBindings = params.map((p) => ':final ${p.name}').join(', ');
        buffer.writeln(
          '      $subclassName($paramBindings) => '
          '${toCamelCase(subclassName)}(${params.map((p) => p.name).join(', ')}),',
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
    for (final candidate in library.classes) {
      if (candidate.supertype?.element == sealedClass) {
        subclasses.add(candidate);
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

    final constructor = constructors.firstWhere(
      (c) => !c.isPrivate,
      orElse: () => constructors.first,
    );

    for (final param in constructor.formalParameters) {
      if (param.isNamed || param.isOptionalPositional) {
        continue;
      }
      final name = param.name;
      if (name == null) {
        continue;
      }
      params.add(_Param(name: name, type: param.type.getDisplayString()));
    }

    return params;
  }
}

class _Param {
  _Param({required this.name, required this.type});
  final String name;
  final String type;
}
