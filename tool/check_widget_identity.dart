import 'dart:io';

// This script prints short, sequential diagnostic lines; cascades make the
// output flow harder to scan while adding no useful structure here.
// ignore_for_file: cascade_invocations

/// Repo-local guardrail for common Flutter widget identity traps.
///
/// Design goals:
/// - Fast and dependency-free (no analyzer dependency).
/// - Catch obvious high-risk patterns early (builders without keys, switchers without keyed children).
/// - Allow suppressions with an explicit reason.
///
/// Suppression:
/// - Add `// widget_identity:ignore <reason>` on the same line or the line above
///   the flagged construct.
///
/// Notes:
/// - This is intentionally heuristic; tune over time if false positives show up.
Future<void> main(final List<String> args) async {
  final root = Directory.current;
  final libDir = Directory('${root.path}${Platform.pathSeparator}lib');
  if (!libDir.existsSync()) {
    stderr.writeln('check_widget_identity: no lib/ directory found.');
    exit(0);
  }

  final results = <_Finding>[];

  for (final file in libDir.listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    final lines = await file.readAsLines();
    _scanFile(file.path, lines, results);
  }

  if (results.isEmpty) {
    stdout.writeln('✅ widget identity: no issues found');
    exit(0);
  }

  stderr.writeln('❌ widget identity: found ${results.length} issue(s)');
  stderr.writeln();
  for (final f in results) {
    stderr.writeln('${f.path}:${f.line}: ${f.message}');
    if (f.snippet.trim().isNotEmpty) {
      stderr.writeln('  ${f.snippet.trim()}');
    }
    stderr.writeln('  Suppress with: // widget_identity:ignore <reason>');
    stderr.writeln();
  }
  exit(1);
}

void _scanFile(
  final String path,
  final List<String> lines,
  final List<_Finding> out,
) {
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Builder-based lists.
    if (_containsAny(
      line,
      const [
        'ListView.builder(',
        'ListView.separated(',
        'GridView.builder(',
        'SliverChildBuilderDelegate(',
        'ReorderableListView.builder(',
      ],
    )) {
      if (_isSuppressed(lines, i)) continue;

      final block = _extractParenBlock(lines, i);
      if (block == null) continue;

      final itemBuilderBody =
          _extractItemBuilderBody(block.text) ??
          _extractFirstCallbackBody(block.text);
      if (itemBuilderBody == null) continue;

      if (_returnsIndexedWidget(itemBuilderBody)) {
        out.add(
          _Finding(
            path: path,
            line: i + 1,
            message:
                'Builder returns a prebuilt widget by index; use ListView/GridView children or key each entry before building.',
            snippet: line,
          ),
        );
        continue;
      }

      final returnedCall = _extractReturnedConstructorCall(itemBuilderBody);
      if (returnedCall == null) continue;

      // If the returned widget is obviously inert, ignore.
      if (_isTriviallySafeReturn(returnedCall.constructorName)) continue;

      if (!returnedCall.hasKeyArgument) {
        out.add(
          _Finding(
            path: path,
            line: i + 1,
            message:
                'Builder row returns `${returnedCall.constructorName}` without a stable key.',
            snippet: line,
          ),
        );
      }
      continue;
    }

    // AnimatedSwitcher child identity.
    if (line.contains('AnimatedSwitcher(')) {
      if (_isSuppressed(lines, i)) continue;

      final block = _extractParenBlock(lines, i);
      if (block == null) continue;

      final childExpr = _extractNamedArgExpression(block.text, 'child');
      if (childExpr == null) continue;

      final childCall = _firstConstructorName(childExpr);
      final hasKeyedChild =
          childExpr.contains('KeyedSubtree(') ||
          childExpr.contains('ValueKey(') ||
          childExpr.contains('key:');

      // If the child is const and simple, it’s usually fine.
      final isConstChild = childExpr.trimLeft().startsWith('const ');

      if (!hasKeyedChild && !isConstChild) {
        out.add(
          _Finding(
            path: path,
            line: i + 1,
            message:
                'AnimatedSwitcher child `${childCall ?? 'unknown'}` is not explicitly keyed (mode switching can reuse the wrong subtree).',
            snippet: line,
          ),
        );
      }
    }
  }
}

bool _containsAny(final String s, final List<String> needles) =>
    needles.any(s.contains);

bool _isSuppressed(final List<String> lines, final int idx) {
  final here = lines[idx];
  final prev = idx > 0 ? lines[idx - 1] : '';
  return here.contains('widget_identity:ignore') ||
      prev.contains('widget_identity:ignore');
}

/// Extracts a parenthesis-balanced block starting at [startLine].
_TextBlock? _extractParenBlock(final List<String> lines, final int startLine) {
  final buffer = StringBuffer();
  var open = 0;
  var seenAny = false;

  for (var i = startLine; i < lines.length; i++) {
    final l = lines[i];
    buffer.writeln(l);
    for (final rune in l.runes) {
      final ch = String.fromCharCode(rune);
      if (ch == '(') {
        open++;
        seenAny = true;
      } else if (ch == ')') {
        open--;
      }
    }
    if (seenAny && open <= 0) {
      return _TextBlock(buffer.toString());
    }
  }
  return null;
}

String? _extractItemBuilderBody(final String blockText) {
  final idx = blockText.indexOf('itemBuilder:');
  if (idx < 0) return null;
  final after = blockText.substring(idx);
  final arrowIdx = after.indexOf('=>');
  final openIdx = after.indexOf('{');

  if (arrowIdx >= 0 && (openIdx < 0 || arrowIdx < openIdx)) {
    return after.substring(arrowIdx + 2);
  }

  // Best-effort: capture from first `{` to its matching `}`.
  if (openIdx < 0) return null;

  var depth = 0;
  for (var i = openIdx; i < after.length; i++) {
    final ch = after[i];
    if (ch == '{') depth++;
    if (ch == '}') depth--;
    if (depth == 0) {
      return after.substring(openIdx + 1, i);
    }
  }
  return null;
}

String? _extractFirstCallbackBody(final String blockText) {
  // SliverChildBuilderDelegate takes the builder callback positionally.
  final arrowIdx = blockText.indexOf('=>');
  final openBraceIdx = blockText.indexOf('{');

  if (arrowIdx >= 0 && (openBraceIdx < 0 || arrowIdx < openBraceIdx)) {
    return blockText.substring(arrowIdx + 2);
  }

  if (openBraceIdx < 0) return null;

  var depth = 0;
  for (var i = openBraceIdx; i < blockText.length; i++) {
    final ch = blockText[i];
    if (ch == '{') depth++;
    if (ch == '}') depth--;
    if (depth == 0) {
      return blockText.substring(openBraceIdx + 1, i);
    }
  }
  return null;
}

bool _returnsIndexedWidget(final String body) {
  var s = body.trimLeft();
  if (s.startsWith('return ')) {
    s = s.substring('return '.length).trimLeft();
  }
  return RegExp(r'^[A-Za-z_]\w*\s*\[\s*index\s*\]').hasMatch(s);
}

_ReturnCall? _extractReturnedConstructorCall(final String body) {
  final returnMatches = RegExp(r'\breturn\s+').allMatches(body).toList();
  if (returnMatches.isEmpty) {
    return _extractConstructorCallFromExpression(body);
  }

  for (final match in returnMatches) {
    final afterReturn = body.substring(match.end).trimLeft();
    final call = _extractConstructorCallFromExpression(afterReturn);
    if (call == null) continue;
    if (_isTriviallySafeReturn(call.constructorName)) continue;
    return call;
  }

  return null;
}

_ReturnCall? _extractConstructorCallFromExpression(final String expression) {
  final afterReturn = expression.trimLeft();

  final name = _firstConstructorName(afterReturn);
  if (name == null) return null;

  final callText = _extractConstructorCallText(afterReturn);
  if (callText == null) return null;

  return _ReturnCall(
    constructorName: name,
    callText: callText,
  );
}

String? _extractConstructorCallText(final String text) {
  final openIdx = text.indexOf('(');
  if (openIdx < 0) return null;

  var depth = 0;
  for (var i = openIdx; i < text.length; i++) {
    final ch = text[i];
    if (ch == '(') depth++;
    if (ch == ')') depth--;
    if (depth == 0) {
      return text.substring(0, i + 1);
    }
  }
  return null;
}

String? _firstConstructorName(final String expr) {
  // Handles: const Foo(, Foo(, Foo.bar(.
  final s = expr.trimLeft();
  final noConst = s.startsWith('const ') ? s.substring(6).trimLeft() : s;
  final openIdx = noConst.indexOf('(');
  if (openIdx <= 0) return null;
  return noConst.substring(0, openIdx).trim();
}

String? _extractNamedArgExpression(
  final String blockText,
  final String argName,
) {
  final idx = blockText.indexOf('$argName:');
  if (idx < 0) return null;
  final after = blockText.substring(idx + '$argName:'.length);
  // Take a small slice; good enough for detecting keyed subtree patterns.
  final slice = after.split('\n').take(8).join('\n');
  return slice;
}

bool _isTriviallySafeReturn(final String name) =>
    name.startsWith('_build') ||
    name.startsWith('SizedBox') ||
    name.startsWith('Spacer') ||
    name.startsWith('Divider') ||
    name.startsWith('SliverToBoxAdapter');

class _TextBlock {
  const _TextBlock(this.text);
  final String text;
}

class _ReturnCall {
  const _ReturnCall({
    required this.constructorName,
    required this.callText,
  });

  final String constructorName;
  final String callText;

  bool get hasKeyArgument => callText.contains('key:');
}

class _Finding {
  const _Finding({
    required this.path,
    required this.line,
    required this.message,
    required this.snippet,
  });

  final String path;
  final int line;
  final String message;
  final String snippet;
}
