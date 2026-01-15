# IDE Plugins Guide for BLoC/Cubit Compile-Time Safety

This guide explains how to create IDE plugins and extensions to enhance the developer experience with BLoC/Cubit compile-time safety features.

## Overview

IDE plugins can provide:

- **Code Snippets**: Quick templates for type-safe BLoC patterns
- **Quick Fixes**: Auto-fix common issues (missing guards, non-exhaustive switches)
- **Code Generation**: IDE integration for generators
- **IntelliSense**: Enhanced autocomplete for type-safe patterns
- **Live Templates**: Generate boilerplate code

## Implementation Approaches

### Approach 1: VS Code Extensions (Recommended for Quick Start)

VS Code extensions are easier to create and can provide immediate value through snippets and commands.

### Approach 2: IntelliJ/Android Studio Plugins

More powerful but requires more setup. Better for deep IDE integration.

### Approach 3: Language Server Protocol (LSP) Enhancements

Works across multiple IDEs but requires LSP server development.

## Quick Start: VS Code Snippets

The easiest way to add IDE support is through VS Code snippets. We've created a snippets file that you can use immediately.

**Location**: `.vscode/flutter_bloc_snippets.code-snippets`

**Features**:

- Type-safe cubit access snippets
- Freezed state templates
- Sealed class state templates
- Type-safe BLoC widget templates

**Installation**:

1. Copy `.vscode/flutter_bloc_snippets.code-snippets` to your VS Code user snippets
2. Or place it in `.vscode/` folder in your project

## Creating a VS Code Extension

### Step 1: Setup Extension Project

```bash
npm install -g yo generator-code
yo code
```

Select:

- TypeScript
- New Extension (TypeScript)
- Name: `flutter-bloc-helper`
- Identifier: `flutter-bloc-helper`
- Description: "Enhanced support for Flutter BLoC/Cubit patterns"

### Step 2: Add Extension Dependencies

In `package.json`:

```json
{
  "dependencies": {
    "vscode": "^1.80.0"
  },
  "devDependencies": {
    "@types/vscode": "^1.80.0",
    "@types/node": "^18.0.0",
    "typescript": "^5.0.0"
  }
}
```

### Step 3: Implement Extension Features

#### Feature 1: Code Snippets Provider

Create `src/snippets.ts`:

```typescript
import * as vscode from 'vscode';

export class BlocSnippetsProvider {
  provideCompletionItems(
    document: vscode.TextDocument,
    position: vscode.Position
  ): vscode.CompletionItem[] {
    const snippets: vscode.CompletionItem[] = [];

    // Type-safe cubit access snippet
    const cubitAccess = new vscode.CompletionItem(
      'bloc-cubit-access',
      vscode.CompletionItemKind.Snippet
    );
    cubitAccess.insertText = new vscode.SnippetString(
      'final ${1:cubit} = context.cubit<${2:CubitType}>();'
    );
    cubitAccess.documentation = new vscode.MarkdownString(
      'Type-safe cubit access using context.cubit<T>()'
    );
    snippets.push(cubitAccess);

    // Type-safe state access snippet
    const stateAccess = new vscode.CompletionItem(
      'bloc-state-access',
      vscode.CompletionItemKind.Snippet
    );
    stateAccess.insertText = new vscode.SnippetString(
      'final ${1:state} = context.state<${2:CubitType}, ${3:StateType}>();'
    );
    stateAccess.documentation = new vscode.MarkdownString(
      'Type-safe state access using context.state<C, S>()'
    );
    snippets.push(stateAccess);

    // Freezed state template
    const freezedState = new vscode.CompletionItem(
      'bloc-freezed-state',
      vscode.CompletionItemKind.Snippet
    );
    freezedState.insertText = new vscode.SnippetString(
      `import 'package:freezed_annotation/freezed_annotation.dart';

part '\${TM_FILENAME_BASE}.freezed.dart';

@freezed
abstract class \${1:StateName} with _$\${1:StateName} {
  const factory \${1:StateName}({
    @Default(\${2:defaultValue}) final \${3:Type} \${4:field},
  }) = _\${1:StateName};

  const \${1:StateName}._();
}`
    );
    freezedState.documentation = new vscode.MarkdownString(
      'Freezed state class template'
    );
    snippets.push(freezedState);

    // Sealed class state template
    const sealedState = new vscode.CompletionItem(
      'bloc-sealed-state',
      vscode.CompletionItemKind.Snippet
    );
    sealedState.insertText = new vscode.SnippetString(
      `sealed class \${1:StateName} extends Equatable {
  const \${1:StateName}();

  @override
  List<Object?> get props => <Object?>[];
}

class \${1:StateName}Initial extends \${1:StateName} {
  const \${1:StateName}Initial();
}

class \${1:StateName}Loading extends \${1:StateName} {
  const \${1:StateName}Loading();
}

class \${1:StateName}Loaded extends \${1:StateName} {
  const \${1:StateName}Loaded();
}

class \${1:StateName}Error extends \${1:StateName} {
  const \${1:StateName}Error(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}`
    );
    sealedState.documentation = new vscode.MarkdownString(
      'Sealed class state hierarchy template'
    );
    snippets.push(sealedState);

    // Type-safe BLoC selector
    const blocSelector = new vscode.CompletionItem(
      'bloc-type-safe-selector',
      vscode.CompletionItemKind.Snippet
    );
    blocSelector.insertText = new vscode.SnippetString(
      `TypeSafeBlocSelector<\${1:CubitType}, \${2:StateType}, \${3:SelectedType}>(
  selector: (state) => state.\${4:field},
  builder: (context, \${5:selected}) => \${6:Widget},
)`
    );
    blocSelector.documentation = new vscode.MarkdownString(
      'Type-safe BLoC selector widget'
    );
    snippets.push(blocSelector);

    return snippets;
  }
}
```

#### Feature 2: Quick Fixes

Create `src/quickFixes.ts`:

```typescript
import * as vscode from 'vscode';

export class BlocQuickFixesProvider {
  provideCodeActions(
    document: vscode.TextDocument,
    range: vscode.Range,
    context: vscode.CodeActionContext
  ): vscode.CodeAction[] {
    const actions: vscode.CodeAction[] = [];

    // Fix non-exhaustive switch statements
    const diagnostics = context.diagnostics.filter(
      (d) => d.message.includes('non-exhaustive') || d.message.includes('missing case')
    );

    for (const diagnostic of diagnostics) {
      const fix = new vscode.CodeAction(
        'Add missing switch cases',
        vscode.CodeActionKind.QuickFix
      );
      fix.diagnostics = [diagnostic];
      fix.edit = new vscode.WorkspaceEdit();
      // Add logic to insert missing cases
      actions.push(fix);
    }

    // Fix missing isClosed guards
    const missingGuardDiagnostics = context.diagnostics.filter(
      (d) => d.message.includes('emit') && d.message.includes('async')
    );

    for (const diagnostic of missingGuardDiagnostics) {
      const fix = new vscode.CodeAction(
        'Add isClosed guard before emit',
        vscode.CodeActionKind.QuickFix
      );
      fix.diagnostics = [diagnostic];
      fix.edit = new vscode.WorkspaceEdit();
      // Add logic to insert guard
      actions.push(fix);
    }

    return actions;
  }
}
```

#### Feature 3: Extension Activation

Update `src/extension.ts`:

```typescript
import * as vscode from 'vscode';
import { BlocSnippetsProvider } from './snippets';
import { BlocQuickFixesProvider } from './quickFixes';

export function activate(context: vscode.ExtensionContext) {
  // Register snippets provider
  const snippetsProvider = new BlocSnippetsProvider();
  context.subscriptions.push(
    vscode.languages.registerCompletionItemProvider(
      'dart',
      snippetsProvider,
      '.', // Trigger on dot
      'c', // Trigger on 'c' (for context)
      's'  // Trigger on 's' (for state)
    )
  );

  // Register quick fixes provider
  const quickFixesProvider = new BlocQuickFixesProvider();
  context.subscriptions.push(
    vscode.languages.registerCodeActionsProvider(
      'dart',
      quickFixesProvider,
      {
        providedCodeActionKinds: [vscode.CodeActionKind.QuickFix],
      }
    )
  );

  // Register commands
  context.subscriptions.push(
    vscode.commands.registerCommand(
      'flutter-bloc-helper.generateState',
      () => {
        // Generate state class
        vscode.window.showInformationMessage('Generate State Class');
      }
    )
  );

  console.log('Flutter BLoC Helper extension is now active!');
}

export function deactivate() {}
```

### Step 4: Package and Publish

```bash
npm install -g vsce
vsce package
vsce publish
```

## Creating IntelliJ/Android Studio Plugin

### Step 1: Setup Plugin Project

1. Install IntelliJ IDEA (Community or Ultimate)
2. Install Plugin Development Kit (PDK)
3. Create new project: **IntelliJ Platform Plugin**

### Step 2: Add Plugin Dependencies

In `build.gradle.kts`:

```kotlin
dependencies {
    implementation("com.jetbrains.intellij.idea:ideaIC:2023.1")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
}
```

### Step 3: Implement Plugin Features

#### Feature 1: Live Templates

Create `src/main/resources/liveTemplates/FlutterBloc.xml`:

```xml
<templateSet group="FlutterBloc">
  <template name="bloc-cubit-access" value="final $VAR$ = context.cubit&lt;$CUBIT_TYPE$&gt;();" description="Type-safe cubit access">
    <variable name="VAR" expression="" defaultValue="cubit" alwaysStopAt="true"/>
    <variable name="CUBIT_TYPE" expression="complete()" defaultValue="CubitType" alwaysStopAt="true"/>
    <context>
      <option name="DART_STATEMENT" value="true"/>
    </context>
  </template>

  <template name="bloc-freezed-state" value="import 'package:freezed_annotation/freezed_annotation.dart';&#10;&#10;part '$FILE_NAME$.freezed.dart';&#10;&#10;@freezed&#10;abstract class $STATE_NAME$ with _$$STATE_NAME$ {&#10;  const factory $STATE_NAME$({&#10;    @Default($DEFAULT$) final $TYPE$ $FIELD$;&#10;  }) = _$STATE_NAME$;&#10;&#10;  const $STATE_NAME$._();&#10;}" description="Freezed state class">
    <variable name="FILE_NAME" expression="fileNameWithoutExtension()" defaultValue="" alwaysStopAt="false"/>
    <variable name="STATE_NAME" expression="" defaultValue="StateName" alwaysStopAt="true"/>
    <variable name="DEFAULT" expression="" defaultValue="ViewStatus.initial" alwaysStopAt="true"/>
    <variable name="TYPE" expression="" defaultValue="ViewStatus" alwaysStopAt="true"/>
    <variable name="FIELD" expression="" defaultValue="status" alwaysStopAt="true"/>
    <context>
      <option name="DART_TOP_LEVEL" value="true"/>
    </context>
  </template>
</templateSet>
```

#### Feature 2: Code Inspection

Create `src/main/kotlin/BlocInspection.kt`:

```kotlin
import com.intellij.codeInspection.LocalInspectionTool
import com.intellij.codeInspection.ProblemsHolder
import com.intellij.psi.PsiElementVisitor
import org.jetbrains.kotlin.idea.inspections.AbstractKotlinInspection

class BlocLifecycleGuardInspection : LocalInspectionTool() {
    override fun buildVisitor(
        holder: ProblemsHolder,
        isOnTheFly: Boolean
    ): PsiElementVisitor {
        return BlocLifecycleGuardVisitor(holder)
    }
}

class BlocLifecycleGuardVisitor(
    private val holder: ProblemsHolder
) : PsiElementVisitor() {
    // Implement inspection logic
    // Check for missing isClosed guards before emit() in async methods
}
```

#### Feature 3: Plugin Configuration

Update `src/main/resources/META-INF/plugin.xml`:

```xml
<idea-plugin>
    <id>com.example.flutter-bloc-helper</id>
    <name>Flutter BLoC Helper</name>
    <version>1.0.0</version>
    <vendor>Your Company</vendor>

    <description>
        Enhanced support for Flutter BLoC/Cubit patterns with compile-time safety.
    </description>

    <depends>com.intellij.modules.platform</depends>
    <depends>org.jetbrains.plugins.dart</depends>

    <extensions defaultExtensionNs="com.intellij">
        <codeInsight.template.impl.TemplateContextType
            id="DART_STATEMENT"
            implementationClass="com.intellij.plugins.dart.DartStatementContext"/>

        <localInspection
            language="Dart"
            shortName="BlocLifecycleGuard"
            displayName="Missing BLoC Lifecycle Guard"
            groupName="Flutter BLoC"
            implementationClass="BlocLifecycleGuardInspection"/>
    </extensions>

    <actions>
        <action
            id="GenerateBlocState"
            class="GenerateBlocStateAction"
            text="Generate BLoC State"
            description="Generate a new BLoC state class">
            <add-to-group group-id="NewGroup" anchor="first"/>
        </action>
    </actions>
</idea-plugin>
```

## Language Server Protocol (LSP) Approach

For cross-IDE support, create an LSP server:

### Step 1: Create LSP Server

```dart
// lsp_server/lib/server.dart
import 'package:analysis_server/lsp_protocol/protocol.dart';
import 'package:analysis_server/src/lsp/handlers/handlers.dart';

class BlocLspServer {
  Future<void> initialize() async {
    // Register LSP capabilities
    // - Code completion for type-safe patterns
    // - Code actions for quick fixes
    // - Diagnostics for BLoC patterns
  }

  Future<List<CompletionItem>> provideCompletions(
    TextDocumentPositionParams params,
  ) async {
    // Provide completions for:
    // - context.cubit<T>()
    // - context.state<C, S>()
    // - TypeSafeBlocSelector
    // etc.
  }

  Future<List<CodeAction>> provideCodeActions(
    CodeActionParams params,
  ) async {
    // Provide quick fixes for:
    // - Missing switch cases
    // - Missing lifecycle guards
    // - Non-exhaustive pattern matching
  }
}
```

### Step 2: Register with IDEs

The LSP server can be used by:

- VS Code (via extension)
- IntelliJ/Android Studio (via plugin)
- Any LSP-compatible editor

## Practical Implementation: VS Code Snippets

We've created a practical implementation using VS Code snippets that you can use immediately.

**File**: `.vscode/flutter_bloc_snippets.code-snippets`

This provides:

- Type-safe cubit access snippets
- Freezed state templates
- Sealed class templates
- Type-safe widget templates

## Testing IDE Plugins

### VS Code Extension Testing

```bash
# Run extension in development
code --extensionDevelopmentPath=./path/to/extension
```

### IntelliJ Plugin Testing

1. Run plugin from IntelliJ IDEA
2. Opens a new IDE instance with plugin loaded
3. Test features in the new instance

## Distribution

### VS Code Extension

1. Package: `vsce package`
2. Publish to Marketplace: `vsce publish`
3. Or distribute `.vsix` file manually

### IntelliJ Plugin

1. Build: `./gradlew buildPlugin`
2. Creates `.zip` file in `build/distributions/`
3. Install via: **Settings → Plugins → Install Plugin from Disk**

## Best Practices

1. **Start Simple**: Begin with snippets/templates before full plugins
2. **User Feedback**: Gather feedback before implementing complex features
3. **Documentation**: Provide clear documentation for all features
4. **Testing**: Test across different IDE versions
5. **Performance**: Ensure plugins don't slow down IDE

## Related Documentation

- [Custom Lint Rules Guide](custom_lint_rules_guide.md) - For analyzer-based validation
- [Code Generation Guide](code_generation_guide.md) - For code generation features
- [Compile-Time Safety Guide](compile_time_safety.md) - Usage patterns for IDE support

## Next Steps

1. **Immediate**: Use the VS Code snippets file (`.vscode/flutter_bloc_snippets.code-snippets`)
2. **Short-term**: Create VS Code extension with snippets and basic quick fixes
3. **Long-term**: Develop full IntelliJ plugin or LSP server for cross-IDE support
