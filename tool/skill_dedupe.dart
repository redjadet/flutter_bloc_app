import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Build duplicate clusters for SKILL.md inventory JSON.
///
/// Usage:
///   dart run tool/skill_dedupe.dart <inventory.json> <out.json>
///
/// Output:
///   {
///     generatedAt,
///     inventoryPath,
///     exactClusters: [{hash, paths:[...]}],
///     nearClusters: [{fingerprint, paths:[...]}]
///   }
Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
      'Usage: dart run tool/skill_dedupe.dart <inventory.json> <out.json>',
    );
    exitCode = 2;
    return;
  }

  final invPath = args[0];
  final outPath = args[1];

  final inv =
      jsonDecode(await File(invPath).readAsString()) as Map<String, Object?>;
  final skills = (inv['skills'] as List).cast<Map<String, Object?>>();

  final exact = <String, List<String>>{};
  final near = <String, List<String>>{};

  for (final s in skills) {
    final path = s['path'] as String;
    final content = await File(path).readAsString();

    final exactKey = _sha1(content);
    (exact[exactKey] ??= []).add(path);

    final fp = _fingerprint(content);
    (near[fp] ??= []).add(path);
  }

  final exactClusters =
      exact.entries
          .where((e) => e.value.length > 1)
          .map((e) => {'hash': e.key, 'paths': e.value})
          .toList()
        ..sort(
          (a, b) => (b['paths'] as List).length.compareTo(
            (a['paths'] as List).length,
          ),
        );

  final nearClusters =
      near.entries
          .where((e) => e.value.length > 1)
          .map((e) => {'fingerprint': e.key, 'paths': e.value})
          .toList()
        ..sort(
          (a, b) => (b['paths'] as List).length.compareTo(
            (a['paths'] as List).length,
          ),
        );

  final payload = <String, Object?>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'inventoryPath': invPath,
    'exactClusters': exactClusters,
    'nearClusters': nearClusters,
  };

  final outFile = File(outPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );
  stdout.writeln(
    'Wrote ${exactClusters.length} exact, ${nearClusters.length} near -> $outPath',
  );
}

String _fingerprint(String content) {
  // Drop YAML frontmatter, normalize whitespace, drop URLs, keep only first 10k chars to bound cost.
  var body = content;
  if (body.startsWith('---')) {
    final end = body.indexOf('\n---', 3);
    if (end != -1) {
      final after = body.indexOf('\n', end + 4);
      body = after == -1 ? '' : body.substring(after + 1);
    }
  }
  body = body.toLowerCase();
  body = body.replaceAll(RegExp(r'https?://\\S+'), '<url>');
  body = body.replaceAll(RegExp(r'`[^`]*`'), '<code>');
  body = body.replaceAll(RegExp(r'\\s+'), ' ').trim();
  if (body.length > 10000) body = body.substring(0, 10000);
  return _sha1(body);
}

String _sha1(String input) {
  final bytes = utf8.encode(input);
  final digest = _sha1Bytes(bytes);
  final sb = StringBuffer();
  for (final b in digest) {
    sb.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}

Uint8List _sha1Bytes(List<int> message) {
  // Minimal SHA-1 implementation (FIPS PUB 180-4 style).
  final ml = message.length * 8;

  // Pre-processing: padding.
  final buffer = BytesBuilder(copy: false)..add(message);
  buffer.addByte(0x80);
  while ((buffer.length + 8) % 64 != 0) {
    buffer.addByte(0x00);
  }
  final lenBytes = ByteData(8)..setUint64(0, ml, Endian.big);
  buffer.add(lenBytes.buffer.asUint8List());
  final data = buffer.toBytes();

  var h0 = 0x67452301;
  var h1 = 0xEFCDAB89;
  var h2 = 0x98BADCFE;
  var h3 = 0x10325476;
  var h4 = 0xC3D2E1F0;

  final w = List<int>.filled(80, 0);

  for (var i = 0; i < data.length; i += 64) {
    final chunk = data.sublist(i, i + 64);
    final bd = ByteData.sublistView(Uint8List.fromList(chunk));

    for (var t = 0; t < 16; t++) {
      w[t] = bd.getUint32(t * 4, Endian.big);
    }
    for (var t = 16; t < 80; t++) {
      w[t] = _rotl32(w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16], 1);
    }

    var a = h0;
    var b = h1;
    var c = h2;
    var d = h3;
    var e = h4;

    for (var t = 0; t < 80; t++) {
      final f = t < 20
          ? ((b & c) | ((~b) & d))
          : t < 40
          ? (b ^ c ^ d)
          : t < 60
          ? ((b & c) | (b & d) | (c & d))
          : (b ^ c ^ d);
      final k = t < 20
          ? 0x5A827999
          : t < 40
          ? 0x6ED9EBA1
          : t < 60
          ? 0x8F1BBCDC
          : 0xCA62C1D6;

      final temp = (_rotl32(a, 5) + f + e + k + w[t]) & 0xFFFFFFFF;
      e = d;
      d = c;
      c = _rotl32(b, 30);
      b = a;
      a = temp;
    }

    h0 = (h0 + a) & 0xFFFFFFFF;
    h1 = (h1 + b) & 0xFFFFFFFF;
    h2 = (h2 + c) & 0xFFFFFFFF;
    h3 = (h3 + d) & 0xFFFFFFFF;
    h4 = (h4 + e) & 0xFFFFFFFF;
  }

  final out = ByteData(20)
    ..setUint32(0, h0, Endian.big)
    ..setUint32(4, h1, Endian.big)
    ..setUint32(8, h2, Endian.big)
    ..setUint32(12, h3, Endian.big)
    ..setUint32(16, h4, Endian.big);
  return out.buffer.asUint8List();
}

int _rotl32(int v, int n) => ((v << n) | (v >>> (32 - n))) & 0xFFFFFFFF;
