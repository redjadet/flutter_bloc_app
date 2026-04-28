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
  final scanFiles = _resolveScanFiles(root, args);
  if (scanFiles.isEmpty) {
    stderr.writeln('check_widget_identity: no Dart files found.');
    exit(0);
  }

  final fileLines = <String, List<String>>{};
  for (final file in scanFiles) {
    fileLines[file.path] = await file.readAsLines();
  }

  final localStateOwners = _findLocalStateOwnerWidgets(fileLines);
  final results = <_Finding>[];

  for (final entry in fileLines.entries) {
    _scanFile(entry.key, entry.value, localStateOwners, results);
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
  final Set<String> localStateOwners,
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

    // Dynamic children lists can shift sibling slots across rebuilds. If a
    // child owns local editing/focus state, require explicit identity.
    if (line.contains('children:')) {
      final block = _extractChildrenListBlock(lines, i);
      if (block == null) continue;
      if (!_isRebuildProneChildrenList(block.text)) continue;

      out.addAll(
        _findUnkeyedLocalStateOwnerCalls(
          path: path,
          lines: lines,
          block: block,
          ownerNames: localStateOwners,
        ),
      );
    }
  }
}

List<File> _resolveScanFiles(final Directory root, final List<String> args) {
  final scanRoots = args.isEmpty
      ? <FileSystemEntity>[
          Directory('${root.path}${Platform.pathSeparator}lib'),
        ]
      : args
            .map(
              (arg) =>
                  FileSystemEntity.typeSync(arg) ==
                      FileSystemEntityType.directory
                  ? Directory(arg)
                  : File(arg),
            )
            .toList();

  final files = <File>[];
  for (final entity in scanRoots) {
    if (!entity.existsSync()) continue;
    if (entity is File) {
      if (entity.path.endsWith('.dart')) files.add(entity);
      continue;
    }
    if (entity is Directory) {
      for (final file in entity.listSync(recursive: true).whereType<File>()) {
        if (file.path.endsWith('.dart')) files.add(file);
      }
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

Set<String> _findLocalStateOwnerWidgets(
  final Map<String, List<String>> fileLines,
) {
  final owners = <String>{};

  for (final lines in fileLines.values) {
    final text = lines.join('\n');
    for (final widgetMatch in RegExp(
      r'class\s+([A-Za-z_]\w*)\s+extends\s+StatefulWidget\b',
    ).allMatches(text)) {
      final widgetName = widgetMatch.group(1)!;
      final widgetBlock = _extractBraceBlockText(text, widgetMatch.start);
      if (widgetBlock != null && _ownsLocalControllerOrFocus(widgetBlock)) {
        owners.add(widgetName);
        continue;
      }

      final stateMatch = RegExp(
        r'class\s+([A-Za-z_]\w*)\s+extends\s+State<'
        '${RegExp.escape(widgetName)}'
        r'>\s*\{',
      ).firstMatch(text);
      if (stateMatch == null) continue;

      final stateBlock = _extractBraceBlockText(text, stateMatch.start);
      if (stateBlock != null && _ownsLocalControllerOrFocus(stateBlock)) {
        owners.add(widgetName);
      }
    }
  }

  return owners;
}

bool _ownsLocalControllerOrFocus(final String classBlock) =>
    classBlock.contains('TextEditingController(') ||
    classBlock.contains('FocusNode(');

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

_TextBlock? _extractChildrenListBlock(
  final List<String> lines,
  final int startLine,
) {
  final buffer = StringBuffer();
  var open = 0;
  var seenList = false;

  for (var i = startLine; i < lines.length; i++) {
    final l = lines[i];
    final scanFrom = i == startLine ? l.indexOf('children:') : 0;
    final text = scanFrom < 0 ? l : l.substring(scanFrom);
    buffer.writeln(text);

    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      if (ch == '[') {
        open++;
        seenList = true;
      } else if (ch == ']') {
        open--;
      }
    }
    if (seenList && open <= 0) {
      return _TextBlock(buffer.toString(), startLine);
    }
  }
  return null;
}

String? _extractBraceBlockText(final String text, final int classStart) {
  final openIdx = text.indexOf('{', classStart);
  if (openIdx < 0) return null;

  var depth = 0;
  for (var i = openIdx; i < text.length; i++) {
    final ch = text[i];
    if (ch == '{') depth++;
    if (ch == '}') depth--;
    if (depth == 0) {
      return text.substring(openIdx, i + 1);
    }
  }
  return null;
}

bool _isRebuildProneChildrenList(final String blockText) =>
    _topLevelChildrenEntries(blockText).any((entry) {
      final text = entry.text.trimLeft();
      return text.startsWith('...') ||
          RegExp(r'^if\s*\(').hasMatch(text) ||
          RegExp(r'^for\s*\(').hasMatch(text) ||
          text.startsWith('List.generate(') ||
          text.startsWith('Iterable.generate(');
    });

List<_Finding> _findUnkeyedLocalStateOwnerCalls({
  required final String path,
  required final List<String> lines,
  required final _TextBlock block,
  required final Set<String> ownerNames,
}) {
  if (ownerNames.isEmpty) return const [];

  final findings = <_Finding>[];
  for (final entry in _topLevelChildrenEntries(block.text)) {
    final entryText = entry.text.trimLeft();
    final constructorName = _firstConstructorName(entryText);
    if (constructorName == null || !ownerNames.contains(constructorName)) {
      continue;
    }

    final callText = _extractConstructorCallText(entryText);
    if (callText == null || callText.contains('key:')) continue;

    final ownerOffset = entry.text.indexOf(constructorName);
    final startOffset = entry.startOffset + (ownerOffset < 0 ? 0 : ownerOffset);
    final line =
        block.startLine +
        block.text.substring(0, startOffset).split('\n').length;
    if (_isSuppressed(lines, line - 1)) continue;

    findings.add(
      _Finding(
        path: path,
        line: line,
        message:
            'Dynamic children list instantiates local state owner `$constructorName` without a stable key.',
        snippet: lines[line - 1],
      ),
    );
  }
  return findings;
}

List<_ChildEntry> _topLevelChildrenEntries(final String blockText) {
  final openIdx = blockText.indexOf('[');
  if (openIdx < 0) return const [];

  var listDepth = 0;
  var parenDepth = 0;
  var braceDepth = 0;
  var entryStart = openIdx + 1;
  final entries = <_ChildEntry>[];

  for (var i = openIdx; i < blockText.length; i++) {
    final ch = blockText[i];
    if (ch == '(') parenDepth++;
    if (ch == ')') parenDepth--;
    if (ch == '{') braceDepth++;
    if (ch == '}') braceDepth--;
    if (ch == '[') {
      listDepth++;
      continue;
    }
    if (ch == ']') {
      listDepth--;
      if (listDepth == 0) {
        _addChildEntry(entries, blockText, entryStart, i);
        break;
      }
      continue;
    }
    if (ch == ',' && listDepth == 1 && parenDepth == 0 && braceDepth == 0) {
      _addChildEntry(entries, blockText, entryStart, i);
      entryStart = i + 1;
    }
  }

  return entries;
}

void _addChildEntry(
  final List<_ChildEntry> entries,
  final String blockText,
  final int start,
  final int end,
) {
  final text = blockText.substring(start, end);
  if (text.trim().isEmpty) return;
  entries.add(_ChildEntry(text, start));
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
  const _TextBlock(this.text, [this.startLine = 0]);
  final String text;
  final int startLine;
}

class _ChildEntry {
  const _ChildEntry(this.text, this.startOffset);
  final String text;
  final int startOffset;
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
