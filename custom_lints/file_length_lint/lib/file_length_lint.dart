import 'dart:io';

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yaml/yaml.dart';

final _configResolver = _FileLengthConfigResolver();

PluginBase createPlugin() => _FileLengthLintPlugin();

class _FileLengthLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const <LintRule>[
    FileLengthLintRule(),
  ];
}

/// Lint rule that checks if a file exceeds the maximum allowed number of lines.
class FileLengthLintRule extends DartLintRule {
  static const LintCode _code = LintCode(
    name: 'file_too_long',
    problemMessage:
        'File has {0} lines (max allowed: {1}). Consider splitting it.',
    correctionMessage: 'Split the file into smaller pieces or extract helpers.',
  );

  const FileLengthLintRule() : super(code: _code);

  static const int _defaultMaxLines = 275;

  static const List<String> _defaultExcludedPatterns = <String>[
    '**/*.g.dart',
    '**/*.freezed.dart',
    '**/*.gen.dart',
    '**/*.gr.dart',
    '**/*.mocks.dart',
    '**/*.part.dart',
    'lib/l10n/**',
    // Root-level paths
    'test/**',
    'tool/**',
    'integration_test/**',
    // Nested paths
    '**/test/**',
    '**/tool/**',
    '**/integration_test/**',
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((CompilationUnit unit) {
      final _ResolvedFileLengthConfig resolved = _configResolver.resolve(
        resolver,
      );
      final _FileLengthConfig config = resolved.config;

      final String absPath = resolver.source.fullName.replaceAll(r'\', '/');
      final String path = _makePathRelativeTo(
        absPath: absPath,
        baseDir: resolved.optionsDirPath,
      );

      if (config.isExcluded(path)) {
        return;
      }

      final int lineCount = unit.lineInfo.lineCount;
      final int maxLines = config.maxLines;
      if (lineCount > maxLines) {
        reporter.atOffset(
          offset: 0,
          length: 0,
          errorCode: _code,
          arguments: <Object>[lineCount, maxLines],
        );
      }
    });
  }
}

class _FileLengthConfig {
  const _FileLengthConfig({
    required this.maxLines,
    required List<_Glob> excludeGlobs,
  }) : _excludeGlobs = excludeGlobs;

  factory _FileLengthConfig.defaults() => _FileLengthConfig(
    maxLines: FileLengthLintRule._defaultMaxLines,
    excludeGlobs: List<_Glob>.unmodifiable(_defaultExcludeGlobs),
  );

  final int maxLines;
  final List<_Glob> _excludeGlobs;

  bool isExcluded(String path) {
    for (final _Glob glob in _excludeGlobs) {
      if (glob.matches(path)) {
        return true;
      }
    }
    return false;
  }
}

class _FileLengthConfigResolver {
  final Map<String, _CachedConfig> _cache = <String, _CachedConfig>{};
  final Map<String, String?> _optionsPathCache = <String, String?>{};

  _ResolvedFileLengthConfig resolve(CustomLintResolver resolver) {
    final String absPath = resolver.source.fullName.replaceAll(r'\', '/');
    final File file = File(absPath);

    final String? optionsPath = _locateOptionsFile(file);
    if (optionsPath == null) {
      return _ResolvedFileLengthConfig(
        config: _FileLengthConfig.defaults(),
        optionsDirPath: _normalizedPath(file.parent.path),
      );
    }

    final File optionsFile = File(optionsPath);
    final int stamp = _modificationStamp(optionsFile);
    final _CachedConfig? cached = _cache[optionsPath];
    if (cached != null && cached.modificationStamp == stamp) {
      return _ResolvedFileLengthConfig(
        config: cached.config,
        optionsDirPath: _normalizedPath(optionsFile.parent.path),
      );
    }

    final _FileLengthConfig config = _loadFromOptions(optionsFile);
    _cache[optionsPath] = _CachedConfig(config, stamp);
    return _ResolvedFileLengthConfig(
      config: config,
      optionsDirPath: _normalizedPath(optionsFile.parent.path),
    );
  }

  String? _locateOptionsFile(File file) {
    Directory current = file.parent;
    final List<Directory> visited = <Directory>[];
    while (true) {
      final String folderPath = current.path;
      if (_optionsPathCache.containsKey(folderPath)) {
        final String? cached = _optionsPathCache[folderPath];
        for (final Directory folder in visited) {
          _optionsPathCache[folder.path] = cached;
        }
        return cached;
      }
      visited.add(current);

      final File candidate = File(
        _normalizedPath('${current.path}/analysis_options.yaml'),
      );
      if (candidate.existsSync()) {
        final String path = candidate.path;
        for (final Directory folder in visited) {
          _optionsPathCache[folder.path] = path;
        }
        _optionsPathCache[folderPath] = path;
        return path;
      }

      final Directory parent = current.parent;
      if (parent.path == current.path) {
        for (final Directory folder in visited) {
          _optionsPathCache[folder.path] = null;
        }
        _optionsPathCache[folderPath] = null;
        return null;
      }

      current = parent;
    }
  }

  _FileLengthConfig _loadFromOptions(File file) {
    try {
      final dynamic yaml = loadYaml(file.readAsStringSync());
      if (yaml is YamlMap) {
        final dynamic section = yaml['file_length_lint'];
        if (section is YamlMap) {
          final int? configuredMaxLines = _asPositiveInt(section['max_lines']);
          final bool includeDefaults =
              section['include_defaults'] != false; // defaults to true
          final Iterable<String> extraPatterns = _asStringIterable(
            section['excludes'],
          );

          final List<_Glob> excludeGlobs = <_Glob>[
            if (includeDefaults) ..._defaultExcludeGlobs,
            ...extraPatterns.map(_Glob.new),
          ];

          final int maxLines =
              configuredMaxLines ?? FileLengthLintRule._defaultMaxLines;

          return _FileLengthConfig(
            maxLines: maxLines,
            excludeGlobs: List<_Glob>.unmodifiable(excludeGlobs),
          );
        }
      }
    } on Object {
      // Fall back to defaults if the options file is invalid or unreadable.
    }
    return _FileLengthConfig.defaults();
  }

  int? _asPositiveInt(Object? value) {
    if (value is int && value > 0) {
      return value;
    }
    if (value is num) {
      final int intValue = value.toInt();
      return intValue > 0 ? intValue : null;
    }
    return null;
  }

  Iterable<String> _asStringIterable(Object? value) {
    if (value is YamlList) {
      return value
          .whereType<Object?>()
          .whereType<String>()
          .map((String pattern) => pattern.trim())
          .where((String pattern) => pattern.isNotEmpty);
    }
    if (value is Iterable<Object?>) {
      return value
          .whereType<String>()
          .map((String pattern) => pattern.trim())
          .where((String pattern) => pattern.isNotEmpty);
    }
    return const Iterable<String>.empty();
  }
}

class _CachedConfig {
  const _CachedConfig(this.config, this.modificationStamp);

  final _FileLengthConfig config;
  final int modificationStamp;
}

class _ResolvedFileLengthConfig {
  const _ResolvedFileLengthConfig({
    required this.config,
    required this.optionsDirPath,
  });

  final _FileLengthConfig config;
  final String optionsDirPath;
}

String _normalizedPath(String path) => path.replaceAll(r'\', '/');

String _makePathRelativeTo({required String absPath, required String baseDir}) {
  final String p = _normalizedPath(absPath);
  final String base = _normalizedPath(baseDir);
  final String prefix = base.endsWith('/') ? base : '$base/';
  if (p.startsWith(prefix)) {
    return p.substring(prefix.length);
  }
  return p;
}

int _modificationStamp(File file) {
  try {
    return file.lastModifiedSync().millisecondsSinceEpoch;
  } on Object {
    return -1;
  }
}

/// Minimal glob matcher for our use case to avoid adding the `glob` package.
class _Glob {
  _Glob(final String pattern) : _regex = _createRegex(pattern);

  final Pattern _regex;

  bool matches(final String input) => (_regex as RegExp).hasMatch(input);

  static RegExp _createRegex(final String pattern) {
    final StringBuffer buffer = StringBuffer('^');
    for (int i = 0; i < pattern.length; i += 1) {
      final String char = pattern[i];
      switch (char) {
        case '*':
          if (i + 1 < pattern.length && pattern[i + 1] == '*') {
            buffer.write('.*');
            i += 1;
          } else {
            buffer.write('[^/]*');
          }
          continue;
        case '?':
          buffer.write('[^/]');
          continue;
        default:
          buffer.write(RegExp.escape(char));
      }
    }
    buffer.write(r'$');
    return RegExp(buffer.toString());
  }
}

final List<_Glob> _defaultExcludeGlobs = List<_Glob>.unmodifiable(
  FileLengthLintRule._defaultExcludedPatterns.map(_Glob.new),
);
