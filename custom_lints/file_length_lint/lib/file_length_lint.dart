import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:yaml/yaml.dart';

final _configResolver = _FileLengthConfigResolver();

/// Lint rule that checks if a file exceeds the maximum allowed number of lines.
class FileLengthLintRule extends AnalysisRule {
  FileLengthLintRule()
    : super(
        name: 'file_too_long',
        description: 'File exceeds the configured maximum number of lines.',
      );

  static const int _defaultMaxLines = 250;

  static const List<String> _defaultExcludedPatterns = <String>[
    '**/*.g.dart',
    '**/*.freezed.dart',
    '**/*.gen.dart',
    '**/*.gr.dart',
    '**/*.mocks.dart',
    '**/*.part.dart',
    'lib/l10n/**',
    '**/test/**',
    '**/tool/**',
  ];

  @override
  DiagnosticCode get diagnosticCode => const _FileTooLongCode();

  @override
  bool get canUseParsedResult => true;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _FileLengthVisitor(this, context));
  }
}

class _FileTooLongCode extends LintCode {
  const _FileTooLongCode()
    : super(
        'file_too_long',
        'File has {0} lines (max allowed: {1}). Consider splitting it.',
        correctionMessage:
            'Split the file into smaller pieces or extract helpers.',
        severity: DiagnosticSeverity.WARNING,
      );
}

class _FileLengthVisitor extends RecursiveAstVisitor<void> {
  _FileLengthVisitor(this.rule, this.context);

  final FileLengthLintRule rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final RuleContextUnit? unit = context.currentUnit;
    if (unit == null) {
      return;
    }

    final String path = unit.file.path.replaceAll(r'\', '/');
    final _FileLengthConfig config = _configResolver.resolve(unit.file);

    // Check default exclusions
    if (config.isExcluded(path)) {
      return;
    }

    final int lineCount = unit.unit.lineInfo.lineCount;
    final int maxLines = config.maxLines;

    if (lineCount > maxLines) {
      rule.reportAtOffset(0, 0, arguments: <Object>[lineCount, maxLines]);
    }
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

  _FileLengthConfig resolve(File file) {
    final String? optionsPath = _locateOptionsFile(file);
    if (optionsPath == null) {
      return _FileLengthConfig.defaults();
    }

    final File optionsFile = file.provider.getFile(optionsPath);
    final int stamp = optionsFile.modificationStamp;
    final _CachedConfig? cached = _cache[optionsPath];
    if (cached != null && cached.modificationStamp == stamp) {
      return cached.config;
    }

    final _FileLengthConfig config = _loadFromOptions(optionsFile);
    _cache[optionsPath] = _CachedConfig(config, stamp);
    return config;
  }

  String? _locateOptionsFile(File file) {
    Folder current = file.parent;
    final List<Folder> visited = <Folder>[];
    while (true) {
      final String folderPath = current.path;
      if (_optionsPathCache.containsKey(folderPath)) {
        final String? cached = _optionsPathCache[folderPath];
        for (final Folder folder in visited) {
          _optionsPathCache[folder.path] = cached;
        }
        return cached;
      }
      visited.add(current);

      final File candidate = current.getChildAssumingFile(
        'analysis_options.yaml',
      );
      if (candidate.exists) {
        final String path = candidate.path;
        for (final Folder folder in visited) {
          _optionsPathCache[folder.path] = path;
        }
        _optionsPathCache[folderPath] = path;
        return path;
      }

      if (current.isRoot) {
        for (final Folder folder in visited) {
          _optionsPathCache[folder.path] = null;
        }
        _optionsPathCache[folderPath] = null;
        return null;
      }

      current = current.parent;
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
