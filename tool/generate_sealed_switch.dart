/// Script to generate exhaustive switch helpers for sealed state classes
///
/// Usage:
///   dart run tool/generate_sealed_switch.dart lib/features/remote_config/presentation/cubit/remote_config_state.dart
///
/// This generates a `.switch_helper.dart` file with exhaustive switch helpers.
/// The generated code uses concrete types (not dynamic) and named parameters
/// for boolean-heavy states to satisfy lint rules.

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run tool/generate_sealed_switch.dart <state_file.dart>');
    print(
      '  Can be either the main file (with part directive) or the part file itself',
    );
    exit(1);
  }

  final filePath = args[0];
  final file = File(filePath);
  if (!file.existsSync()) {
    print('Error: File not found: $filePath');
    exit(1);
  }

  final content = file.readAsStringSync();
  final generated = _generateSwitchHelper(content, filePath);

  // Determine output path
  String outputPath;
  if (content.contains("part of")) {
    // Part file - output next to it
    outputPath = filePath.replaceAll('.dart', '.switch_helper.dart');
  } else if (content.contains("part '")) {
    // Main file with part - use part file name
    final partMatch = RegExp(r"part '([^']+)'").firstMatch(content);
    if (partMatch != null) {
      final partFileName = partMatch.group(1)!;
      outputPath = filePath.replaceAll(
        RegExp(r'[^/]+$'),
        partFileName.replaceAll('.dart', '.switch_helper.dart'),
      );
    } else {
      outputPath = filePath.replaceAll('.dart', '.switch_helper.dart');
    }
  } else {
    outputPath = filePath.replaceAll('.dart', '.switch_helper.dart');
  }

  final outputFile = File(outputPath);
  outputFile.writeAsStringSync(generated);

  print('Generated: $outputPath');
}

String _generateSwitchHelper(String content, String filePath) {
  // Check if this is a main file with part directive
  String searchContent = content;
  if (content.contains("part '")) {
    // This is the main file, find and read the part file
    final partMatch = RegExp(r"part '([^']+)'").firstMatch(content);
    if (partMatch != null) {
      final partFileName = partMatch.group(1)!;
      final partFilePath = filePath.replaceAll(RegExp(r'[^/]+$'), partFileName);
      final partFile = File(partFilePath);
      if (partFile.existsSync()) {
        searchContent = partFile.readAsStringSync();
      }
    }
  }

  // Extract sealed class name
  final sealedMatch = RegExp(
    r'sealed\s+class\s+(\w+)',
  ).firstMatch(searchContent);
  if (sealedMatch == null) {
    throw Exception('No sealed class found in file or part file');
  }
  final className = sealedMatch.group(1)!;

  // Extract subclass names
  final lines = searchContent.split('\n');
  final subclasses = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    // Match "class Xxx extends RemoteConfigState"
    if (line.contains('class ') && line.contains('extends $className')) {
      final match = RegExp(r'class\s+(\w+)\s+extends').firstMatch(line);
      if (match != null) {
        final subclassName = match.group(1)!;
        if (subclassName != className) {
          subclasses.add(subclassName);
        }
      }
    }
  }

  if (subclasses.isEmpty) {
    throw Exception('No subclasses found for sealed class $className');
  }

  // Extract constructor parameters for each subclass
  final subclassParams = <String, List<_Param>>{};

  for (final subclassName in subclasses) {
    final params = _extractParams(subclassName, searchContent);
    subclassParams[subclassName] = params;
  }

  // Generate the extension
  final buffer = StringBuffer();
  final fileName = filePath.split('/').last.replaceAll('.dart', '');
  if (searchContent.contains("part of")) {
    final partOfMatch = RegExp(r"part of '([^']+)'").firstMatch(searchContent);
    if (partOfMatch != null) {
      buffer.writeln("part of '${partOfMatch.group(1)!}';");
    } else {
      buffer.writeln("part of '$fileName.dart';");
    }
  } else {
    buffer.writeln("part of '$fileName.dart';");
  }
  buffer.writeln();
  buffer.writeln('// Generated exhaustive switch helper for $className');
  buffer.writeln('extension ${className}SwitchHelper on $className {');
  buffer.writeln('  /// Exhaustive pattern matching helper');
  buffer.writeln('  T when<T>({');

  // Generate parameters
  for (final subclassName in subclasses) {
    final params = subclassParams[subclassName] ?? [];
    final camelName = _toCamelCase(subclassName);
    if (params.isEmpty) {
      buffer.writeln('    required final T Function() $camelName,');
    } else {
      // Check if we should use named parameters
      final hasBoolean = params.any((p) => p.type == 'bool');
      final usesNamedConstructor = _usesNamedConstructor(
        subclassName,
        searchContent,
      );
      final shouldUseNamed = hasBoolean || usesNamedConstructor;

      if (shouldUseNamed && params.length > 1) {
        // Generate named parameters
        buffer.writeln('    required final T Function({');
        for (final param in params) {
          final required = param.isRequired ? 'required ' : '';
          buffer.writeln('      $required${param.type} ${param.name},');
        }
        buffer.writeln('    }) $camelName,');
      } else {
        // Generate positional parameters
        final paramList = params.map((p) => '${p.type} ${p.name}').join(', ');
        buffer.writeln('    required final T Function($paramList) $camelName,');
      }
    }
  }

  buffer.writeln('  }) => switch (this) {');

  // Generate switch cases
  for (final subclassName in subclasses) {
    final params = subclassParams[subclassName] ?? [];
    final camelName = _toCamelCase(subclassName);
    if (params.isEmpty) {
      buffer.writeln('    $subclassName() => $camelName(),');
    } else {
      final bindings = params.map((p) => ':final ${p.name}').join(', ');
      final hasBoolean = params.any((p) => p.type == 'bool');
      final usesNamedConstructor = _usesNamedConstructor(
        subclassName,
        searchContent,
      );
      final shouldUseNamed = hasBoolean || usesNamedConstructor;

      if (shouldUseNamed && params.length > 1) {
        // Use named arguments
        final namedArgs = params
            .map((p) => '${p.name}: ${p.name}')
            .join(',\n        ');
        buffer.writeln('    $subclassName($bindings) =>');
        buffer.writeln('      $camelName(');
        buffer.writeln('        $namedArgs,');
        buffer.writeln('      ),');
      } else {
        // Use positional arguments
        final args = params.map((p) => p.name).join(', ');
        buffer.writeln('    $subclassName($bindings) => $camelName($args),');
      }
    }
  }

  buffer.writeln('  };');
  buffer.writeln('}');

  return buffer.toString();
}

bool _usesNamedConstructor(String className, String content) {
  // Check if constructor uses named parameters (has {})
  final constructorMatch = RegExp(
    r'const\s+$className\s*\(\s*\{',
    multiLine: true,
  ).firstMatch(content);
  return constructorMatch != null;
}

List<_Param> _extractParams(String className, String content) {
  final params = <_Param>[];

  // Find the class definition
  final classStart = content.indexOf('class $className');
  if (classStart == -1) {
    return params;
  }

  // Find the class block
  final classEnd = _findClassEnd(content, classStart);
  final classContent = content.substring(classStart, classEnd);

  // Find constructor - handle both named and positional
  final constructorStart = classContent.indexOf('const $className(');
  if (constructorStart == -1) {
    return params;
  }

  // Find the matching closing parenthesis
  int parenDepth = 0;
  int braceDepth = 0;
  int endPos = constructorStart;
  bool foundStart = false;
  bool isNamed = false;

  for (int i = constructorStart; i < classContent.length; i++) {
    if (classContent[i] == '(') {
      parenDepth++;
      foundStart = true;
    } else if (classContent[i] == '{') {
      braceDepth++;
      if (foundStart && parenDepth == 1) {
        isNamed = true;
      }
    } else if (classContent[i] == '}') {
      braceDepth--;
    } else if (classContent[i] == ')') {
      parenDepth--;
      if (foundStart && parenDepth == 0) {
        endPos = i + 1;
        break;
      }
    }
  }

  if (endPos <= constructorStart) {
    return params;
  }

  final constructorBlock = classContent.substring(constructorStart, endPos);
  final paramString = _extractParamString(constructorBlock, isNamed);

  if (paramString.isEmpty) {
    return params;
  }

  // Parse the parameters
  final paramLines = paramString
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  for (final paramLine in paramLines) {
    // Pass both classContent and full content for better type extraction
    final param = _parseParameter(paramLine, content);
    if (param != null) {
      params.add(param);
    }
  }

  return params;
}

String _extractParamString(String constructorBlock, bool isNamed) {
  if (isNamed) {
    // Extract content between { }
    final braceMatch = RegExp(r'\{([^}]*)\}').firstMatch(constructorBlock);
    return braceMatch?.group(1)?.trim() ?? '';
  } else {
    // Extract content between ( )
    final parenMatch = RegExp(r'\(([^)]*)\)').firstMatch(constructorBlock);
    return parenMatch?.group(1)?.trim() ?? '';
  }
}

_Param? _parseParameter(String paramLine, String classContent) {
  // Handle "required this.field" or "this.field" (named parameters)
  if (paramLine.contains('this.')) {
    final fieldMatch = RegExp(r'this\.(\w+)').firstMatch(paramLine);
    if (fieldMatch != null) {
      final fieldName = fieldMatch.group(1)!;
      final isRequired = paramLine.contains('required');
      // Search in the full content, not just classContent, to find field declarations
      // that might be in a different part of the file
      final type = _extractFieldType(fieldName, classContent);
      return _Param(
        name: fieldName,
        type: type,
        isRequired: isRequired,
      );
    }
  }

  // Handle positional: "Type field" or "final Type field"
  final typeFieldMatch = RegExp(
    r'(?:required\s+)?(?:final\s+)?(\S+)\s+(\w+)',
  ).firstMatch(paramLine);
  if (typeFieldMatch != null) {
    final type = typeFieldMatch.group(1)!;
    final name = typeFieldMatch.group(2)!;
    final isRequired = paramLine.contains('required');
    return _Param(name: name, type: type, isRequired: isRequired);
  }

  return null;
}

String _extractFieldType(String fieldName, String classContent) {
  // Try multiple patterns to find the field type
  // Look for field declarations in the class body
  // Field declarations typically come after the constructor

  // Pattern 1: "final Type fieldName;" (non-nullable, simple types like bool, String, int)
  // Match: "final bool isAwesomeFeatureEnabled;" or "  final bool isAwesomeFeatureEnabled;"
  // Use word boundaries to ensure we match the exact field name
  var pattern = 'final\\s+([A-Za-z][A-Za-z0-9_]*)\\s+$fieldName\\s*;';
  var match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return match.group(1)!;
  }

  // Pattern 2: "final Type? fieldName;" (nullable simple types)
  // Match: "final String? dataSource;"
  pattern = 'final\\s+([A-Za-z][A-Za-z0-9_]*)\\?\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return '${match.group(1)!}?';
  }

  // Pattern 3: "final List<Type> fieldName;" (generic types, non-nullable)
  // Match: "final List<ChatContact> contacts;"
  pattern = 'final\\s+(List<[^>]+>)\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return match.group(1)!;
  }

  // Pattern 4: "final List<Type>? fieldName;" (nullable generic)
  pattern = 'final\\s+(List<[^>]+>)\\?\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return '${match.group(1)!}?';
  }

  // Pattern 5: "final Set<Type> fieldName;" (Set types)
  pattern = 'final\\s+(Set<[^>]+>)\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return match.group(1)!;
  }

  // Pattern 6: "final Map<Type1, Type2> fieldName;" (Map types)
  pattern = 'final\\s+(Map<[^>]+>)\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return match.group(1)!;
  }

  // Pattern 7: Complex types with angle brackets (e.g., Future<String>, DateTime)
  // Match: "final DateTime? lastSyncedAt;"
  pattern = 'final\\s+([A-Za-z][A-Za-z0-9_]*<[^>]+>)\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return match.group(1)!;
  }

  // Pattern 8: Complex nullable types with angle brackets
  pattern = 'final\\s+([A-Za-z][A-Za-z0-9_]*<[^>]+>)\\?\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return '${match.group(1)!}?';
  }

  // Pattern 9: Multi-word types like DateTime (non-nullable)
  pattern = 'final\\s+([A-Z][A-Za-z0-9_]*)\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return match.group(1)!;
  }

  // Pattern 10: Multi-word types like DateTime? (nullable)
  pattern = 'final\\s+([A-Z][A-Za-z0-9_]*)\\?\\s+$fieldName\\s*;';
  match = RegExp(
    pattern,
    multiLine: true,
  ).firstMatch(classContent);
  if (match != null) {
    return '${match.group(1)!}?';
  }

  // Last resort: return dynamic (shouldn't happen with proper code)
  print('Warning: Could not extract type for field $fieldName, using dynamic');
  return 'dynamic';
}

int _findClassEnd(String content, int start) {
  int depth = 0;
  bool inClass = false;
  for (int i = start; i < content.length; i++) {
    if (content[i] == '{') {
      depth++;
      inClass = true;
    } else if (content[i] == '}') {
      depth--;
      if (inClass && depth == 0) {
        return i + 1;
      }
    }
  }
  return content.length;
}

String _toCamelCase(String input) {
  if (input.isEmpty) {
    return input;
  }
  // Remove common prefixes
  final withoutPrefix = input.replaceAll(
    RegExp(r'^(RemoteConfig|ChatList|DeepLink)'),
    '',
  );
  if (withoutPrefix.isEmpty) {
    return input[0].toLowerCase() + input.substring(1);
  }
  return withoutPrefix[0].toLowerCase() + withoutPrefix.substring(1);
}

class _Param {
  _Param({
    required this.name,
    required this.type,
    this.isRequired = false,
  });
  final String name;
  final String type;
  final bool isRequired;
}
