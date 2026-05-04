import 'dart:convert';
import 'dart:io';

const String _manifestPath = 'tool/hive_schema_manifest.json';
const String _outPath = 'lib/shared/storage/hive_schema_fingerprints.g.dart';

String _fnv1a64Bytes(final List<int> bytes) {
  final BigInt mask = (BigInt.one << 64) - BigInt.one;
  final BigInt prime = BigInt.parse('100000001b3', radix: 16);
  BigInt hash = BigInt.parse('cbf29ce484222325', radix: 16);
  for (final b in bytes) {
    hash = hash ^ BigInt.from(b & 0xff);
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

String _fnv1a64Hex(final String s) {
  return _fnv1a64Bytes(utf8.encode(s));
}

String _readText(final String path) {
  final String text = File(path).readAsStringSync();
  return text.replaceAll('\r\n', '\n');
}

String _renderGenerated({
  required final Map<String, String> fingerprints,
  required final Map<String, String> inputDigests,
}) {
  final StringBuffer b = StringBuffer()
    ..writeln('// GENERATED FILE. DO NOT EDIT.')
    ..writeln('//')
    ..writeln(
      '// Regenerate: dart run tool/generate_hive_schema_fingerprints.dart',
    )
    ..writeln('//')
    ..writeln(
      'const Map<String, String> hiveSchemaFingerprints = <String, String>{',
    );
  for (final key in (fingerprints.keys.toList()..sort())) {
    b.writeln("  '$key': '${fingerprints[key]}',");
  }
  b
    ..writeln('};')
    ..writeln()
    ..writeln(
      'const Map<String, String> hiveSchemaInputDigests = <String, String>{',
    );
  for (final key in (inputDigests.keys.toList()..sort())) {
    b.writeln("  '$key': '${inputDigests[key]}',");
  }
  b.writeln('};');
  return b.toString();
}

Never _fail(final String message) {
  stderr.writeln(message);
  exit(1);
}

void main(final List<String> args) {
  final bool checkGenerated = args.contains('--check-generated');
  final bool checkInputs = args.contains('--check-inputs');
  final bool enforceInputs = args.contains('--enforce-inputs');

  final Map<String, dynamic> manifest =
      jsonDecode(_readText(_manifestPath)) as Map<String, dynamic>;
  final List<dynamic> boxes =
      manifest['boxes'] as List<dynamic>? ?? <dynamic>[];

  final Map<String, String> fingerprints = <String, String>{};
  final Map<String, String> inputDigests = <String, String>{};

  for (final dynamic box in boxes) {
    final Map<String, dynamic> entry = box as Map<String, dynamic>;
    final String name = (entry['name'] as String?)?.trim() ?? '';
    final String spec = (entry['spec'] as String?)?.trim() ?? '';
    if (name.isEmpty || spec.isEmpty) {
      _fail('Invalid manifest entry: name/spec required');
    }
    fingerprints[name] = _fnv1a64Hex(spec);

    final List<dynamic> inputs =
        entry['inputs'] as List<dynamic>? ?? <dynamic>[];
    for (final dynamic input in inputs) {
      final String path = (input as String).trim();
      if (path.isEmpty) continue;
      inputDigests[path] = _fnv1a64Hex(_readText(path));
    }
  }

  final String rendered = _renderGenerated(
    fingerprints: fingerprints,
    inputDigests: inputDigests,
  );

  final bool outExists = File(_outPath).existsSync();
  final String existing = outExists ? _readText(_outPath) : '';

  if (checkGenerated) {
    if (existing != rendered) {
      _fail(
        'Generated file is stale. Run:\n'
        '  dart run tool/generate_hive_schema_fingerprints.dart\n',
      );
    }
    return;
  }

  if (checkInputs) {
    // Soft check: warn by default, optionally fail with --enforce-inputs.
    final List<String> changed = <String>[];
    for (final entry in inputDigests.entries) {
      final String prev = _extractDigest(existing, entry.key);
      if (prev.isNotEmpty && prev != entry.value) {
        changed.add(entry.key);
      }
    }
    if (changed.isNotEmpty) {
      final String msg =
          'Inputs changed since last generation:\n'
          '${changed.map((e) => ' - $e').join('\n')}\n'
          'Review tool/hive_schema_manifest.json spec strings and regenerate.\n';
      if (enforceInputs) {
        _fail(msg);
      } else {
        stderr.writeln(msg);
      }
    }
    return;
  }

  File(_outPath).writeAsStringSync(rendered);
}

String _extractDigest(final String generatedFile, final String key) {
  final String needle = "  '$key': '";
  final int idx = generatedFile.indexOf(needle);
  if (idx == -1) return '';
  final int start = idx + needle.length;
  final int end = generatedFile.indexOf("'", start);
  if (end == -1) return '';
  return generatedFile.substring(start, end);
}
