import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:memory_lint/src/utils/ast_helpers.dart';
import 'package:test/test.dart';

/// Lightweight AST contract tests.
///
/// Full `AnalysisRuleTest` (analyzer_testing) is currently broken against the
/// pinned analyzer 10.0.2 stack (same as `file_length_lint`). These tests
/// exercise the same syntax predicates the Wave A rules use.
void main() {
  group('memory_state_controller predicates', () {
    test('dispose present on State field', () {
      final ClassDeclaration clazz = _firstClass(r'''
class State<T> {}
class TextEditingController { void dispose() {} }
class Good extends State<Object> {
  late final TextEditingController controller;
  void dispose() { controller.dispose(); }
}
''');
      expect(classExtendsState(clazz), isTrue);
      final MethodDeclaration dispose = _method(clazz, 'dispose')!;
      expect(methodDisposesField(dispose, 'controller'), isTrue);
    });

    test('missing dispose on State field', () {
      final ClassDeclaration clazz = _firstClass(r'''
class State<T> {}
class TextEditingController {}
class Bad extends State<Object> {
  final TextEditingController controller = TextEditingController();
}
''');
      expect(classExtendsState(clazz), isTrue);
      expect(_method(clazz, 'dispose'), isNull);
    });

    test('non-State ignored by extends check', () {
      final ClassDeclaration clazz = _firstClass(r'''
class TextEditingController {}
class Holder {
  final TextEditingController controller;
  Holder(this.controller);
}
''');
      expect(classExtendsState(clazz), isFalse);
    });
  });

  group('memory_stream_controller predicates', () {
    test('closed in dispose', () {
      final ClassDeclaration clazz = _firstClass(r'''
class StreamController<T> { void close() {} }
class Good {
  final StreamController<int> c = StreamController<int>();
  void dispose() { c.close(); }
}
''');
      expect(methodClosesField(_method(clazz, 'dispose')!, 'c'), isTrue);
    });

    test('closed in close', () {
      final ClassDeclaration clazz = _firstClass(r'''
class StreamController<T> { void close() {} }
class Good {
  final StreamController<int> c = StreamController<int>();
  void close() { c.close(); }
}
''');
      expect(methodClosesField(_method(clazz, 'close')!, 'c'), isTrue);
    });

    test('missing close', () {
      final ClassDeclaration clazz = _firstClass(r'''
class StreamController<T> {}
class Bad {
  final StreamController<int> c = StreamController<int>();
}
''');
      expect(_method(clazz, 'dispose'), isNull);
      expect(_method(clazz, 'close'), isNull);
    });
  });

  group('memory_widgets_binding_observer predicates', () {
    test('add and remove', () {
      final ClassDeclaration clazz = _firstClass(r'''
class WidgetsBinding {
  static final WidgetsBinding instance = WidgetsBinding();
  void addObserver(Object o) {}
  void removeObserver(Object o) {}
}
class Good {
  void start() { WidgetsBinding.instance.addObserver(this); }
  void dispose() { WidgetsBinding.instance.removeObserver(this); }
}
''');
      expect(classHasAddObserverThis(clazz), isTrue);
      expect(classHasRemoveObserverThis(clazz), isTrue);
    });

    test('add without remove', () {
      final ClassDeclaration clazz = _firstClass(r'''
class WidgetsBinding {
  static final WidgetsBinding instance = WidgetsBinding();
  void addObserver(Object o) {}
}
class Bad {
  void start() { WidgetsBinding.instance.addObserver(this); }
}
''');
      expect(classHasAddObserverThis(clazz), isTrue);
      expect(classHasRemoveObserverThis(clazz), isFalse);
    });
  });

  group('memory_static_build_context predicates', () {
    test('static BuildContext? detected', () {
      final CompilationUnit unit = parseString(
        content: r'''
class BuildContext {}
class Bad {
  static BuildContext? retained;
  BuildContext? instance;
  static final String label = 'x';
}
''',
      ).unit;
      final ClassDeclaration clazz = unit.declarations
          .whereType<ClassDeclaration>()
          .last;
      final List<FieldDeclaration> staticContexts = clazz.members
          .whereType<FieldDeclaration>()
          .where(
            (FieldDeclaration f) =>
                f.isStatic &&
                declaredBaseTypeName(f.fields.type) == 'BuildContext',
          )
          .toList();
      expect(staticContexts, hasLength(1));
    });
  });
}

ClassDeclaration _firstClass(String source) {
  final CompilationUnit unit = parseString(content: source).unit;
  return unit.declarations.whereType<ClassDeclaration>().last;
}

MethodDeclaration? _method(ClassDeclaration clazz, String name) {
  for (final ClassMember member in clazz.members) {
    if (member is MethodDeclaration &&
        !member.isStatic &&
        member.name.lexeme == name) {
      return member;
    }
  }
  return null;
}
