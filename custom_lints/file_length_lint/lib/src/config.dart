import 'package:analyzer/file_system/file_system.dart';
import 'package:yaml/yaml.dart';

const int defaultMaxLines = 275;

const List<String> defaultExcludedPatterns = <String>[
  '**/*.g.dart',
  '**/*.freezed.dart',
  '**/*.gen.dart',
  '**/*.gr.dart',
  '**/*.mocks.dart',
  '**/*.part.dart',
  'lib/l10n/**',
  'test/**',
  'tool/**',
  'integration_test/**',
  '**/test/**',
  '**/tool/**',
  '**/integration_test/**',
];

final List<Glob> defaultExcludeGlobs = List<Glob>.unmodifiable(
  defaultExcludedPatterns.map(Glob.new),
);

class FileLengthConfig {
  const FileLengthConfig({
    required this.maxLines,
    required List<Glob> excludeGlobs,
  }) : _excludeGlobs = excludeGlobs;

  factory FileLengthConfig.defaults() => FileLengthConfig(
    maxLines: defaultMaxLines,
    excludeGlobs: defaultExcludeGlobs,
  );

  final int maxLines;
  final List<Glob> _excludeGlobs;

  bool isExcluded(String path) {
    for (final Glob glob in _excludeGlobs) {
      if (glob.matches(path)) {
        return true;
      }
    }
    return false;
  }
}

class ResolvedFileLengthConfig {
  const ResolvedFileLengthConfig({
    required this.config,
    required this.optionsDirPath,
  });

  final FileLengthConfig config;
  final String optionsDirPath;
}

class FileLengthConfigResolver {
  final Map<String, _CachedConfig> _cache = <String, _CachedConfig>{};
  final Map<String, String?> _optionsPathCache = <String, String?>{};

  ResolvedFileLengthConfig resolveForUnitFile(File file) {
    final File? optionsFile = _locateOptionsFile(file);
    if (optionsFile == null) {
      return ResolvedFileLengthConfig(
        config: FileLengthConfig.defaults(),
        optionsDirPath: _normalizedPath(file.parent.path),
      );
    }

    final int stamp = optionsFile.modificationStamp;
    final String optionsPath = optionsFile.path;
    final _CachedConfig? cached = _cache[optionsPath];
    if (cached != null && cached.modificationStamp == stamp) {
      return ResolvedFileLengthConfig(
        config: cached.config,
        optionsDirPath: _normalizedPath(optionsFile.parent.path),
      );
    }

    final FileLengthConfig config = _loadFromOptions(optionsFile);
    _cache[optionsPath] = _CachedConfig(config, stamp);
    return ResolvedFileLengthConfig(
      config: config,
      optionsDirPath: _normalizedPath(optionsFile.parent.path),
    );
  }

  File? _locateOptionsFile(File file) {
    Folder current = file.parent;
    final List<Folder> visited = <Folder>[];
    while (true) {
      final String folderPath = current.path;
      if (_optionsPathCache.containsKey(folderPath)) {
        final String? cached = _optionsPathCache[folderPath];
        for (final Folder folder in visited) {
          _optionsPathCache[folder.path] = cached;
        }
        if (cached == null) {
          return null;
        }
        return current.provider.getFile(cached);
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
        return candidate;
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

  FileLengthConfig _loadFromOptions(File file) {
    try {
      final dynamic yaml = loadYaml(file.readAsStringSync());
      if (yaml is YamlMap) {
        final dynamic section = yaml['file_length_lint'];
        if (section is YamlMap) {
          final int? configuredMaxLines = _asPositiveInt(section['max_lines']);
          final bool includeDefaults = section['include_defaults'] != false;
          final Iterable<String> extraPatterns = _asStringIterable(
            section['excludes'],
          );

          final List<Glob> excludeGlobs = <Glob>[
            if (includeDefaults) ...defaultExcludeGlobs,
            ...extraPatterns.map(Glob.new),
          ];

          final int maxLines = configuredMaxLines ?? defaultMaxLines;

          return FileLengthConfig(
            maxLines: maxLines,
            excludeGlobs: List<Glob>.unmodifiable(excludeGlobs),
          );
        }
      }
    } on Object {
      // Fall back to defaults if the options file is invalid or unreadable.
    }
    return FileLengthConfig.defaults();
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

  final FileLengthConfig config;
  final int modificationStamp;
}

String normalizedPath(String path) => path.replaceAll(r'\', '/');

String makePathRelativeTo({required String absPath, required String baseDir}) {
  final String p = normalizedPath(absPath);
  final String base = normalizedPath(baseDir);
  final String prefix = base.endsWith('/') ? base : '$base/';
  if (p.startsWith(prefix)) {
    return p.substring(prefix.length);
  }
  return p;
}

String _normalizedPath(String path) => normalizedPath(path);

/// Minimal glob matcher to avoid adding the `glob` package.
class Glob {
  Glob(String pattern) : _regex = _createRegex(pattern);

  final Pattern _regex;

  bool matches(String input) => (_regex as RegExp).hasMatch(input);

  static RegExp _createRegex(String pattern) {
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
        case '?':
          buffer.write('[^/]');
        default:
          buffer.write(RegExp.escape(char));
      }
    }
    buffer.write(r'$');
    return RegExp(buffer.toString());
  }
}
