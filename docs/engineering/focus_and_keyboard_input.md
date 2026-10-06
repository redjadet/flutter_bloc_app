# Focus and keyboard input

How Flutter routes keystrokes — a **focus tree** separate from the widget /
Element / RenderObject trees. Complements
[`flutter_fundamentals_and_production_practices.md`](flutter_fundamentals_and_production_practices.md)
(three trees + identity) and pointer hit-testing (RenderObject path). Does not
replace dispose rules in
[`../performance/memory_management.md`](../performance/memory_management.md).

Official canon:

- [Understanding Flutter's keyboard focus system](https://docs.flutter.dev/ui/interactivity/focus)
- [Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts)
- [`FocusNode`](https://api.flutter.dev/flutter/widgets/FocusNode-class.html),
  [`FocusScope`](https://api.flutter.dev/flutter/widgets/FocusScope-class.html),
  [`FocusManager`](https://api.flutter.dev/flutter/widgets/FocusManager-class.html),
  [`FocusTraversalPolicy`](https://api.flutter.dev/flutter/widgets/FocusTraversalPolicy-class.html),
  [`TextInput`](https://api.flutter.dev/flutter/services/TextInput-class.html)

---

## Keyboard ≠ pointer

Pointer input resolves targets via **hit-test** on the render tree, then
gesture recognition. Keyboard input resolves via the **focus system**: which
`FocusNode` currently holds **primary focus**, then key-event propagation up
that node's ancestors. Visibility alone does not decide where keystrokes go.

## Focus tree (sparse)

| Concept | Role |
| --- | --- |
| **Focus tree** | Sparse tree of nodes interested in keyboard focus; mirrors focusable parts of the widget tree |
| **`FocusNode`** | One focusable slot; can request primary focus; may handle `onKeyEvent` |
| **`FocusScope` / `FocusScopeNode`** | Groups nodes; remembers last focused child; restricts traversal (routes push a scope) |
| **Primary focus** | Leaf-most focused node — key events **start** here |
| **Focus chain** | Primary focus → ancestors → root scope |
| **`FocusManager`** | Singleton (`FocusManager.instance` / `WidgetsBinding.focusManager`): owns `primaryFocus`, `rootScope`, distributes key events |

Prefer the `Focus` / `FocusScope` widgets for day-to-day work. Own a bare
`FocusNode` mainly when an ancestor must call `requestFocus()` on a descendant
field (forms, dialogs).

Debug: `debugDumpFocusTree` / `debugDescribeFocusTree`.

## Key-event path

1. Platform / `HardwareKeyboard` delivers a key event to `FocusManager`.
2. Manager calls `onKeyEvent` on the **primary focus** node.
3. If the handler returns `KeyEventResult.ignored`, the event moves to the
   **parent** focus node, and so on toward `FocusManager.rootScope`.
4. `KeyEventResult.handled` stops Flutter propagation (and does not hand the
   event to other Flutter widgets).

Traversal (Tab / directional) uses `FocusTraversalPolicy` from a nearby
`FocusTraversalGroup` (defaults include reading order and widget order). Call
`nextFocus` / `previousFocus` / `focusInDirection` on a node to move focus.

## Text fields vs focus

| Layer | What it does |
| --- | --- |
| Focus (`FocusNode` on a `TextField` / `EditableText`) | Decides **which** editable (or other focusable) is active |
| [`TextInput`](https://api.flutter.dev/flutter/services/TextInput-class.html) | Low-level **IME / soft-keyboard** channel: `attach` → `TextInputConnection` to a `TextInputClient` |

Focusing a text field attaches the platform input connection; losing focus
usually closes or reassigns it. Soft-keyboard **Next** / **Done** are
`TextInputAction`s — wire `onSubmitted` / `textInputAction` to
`otherFocusNode.requestFocus()` when the form needs field-to-field advance
(see Todo dialog below). That is not the same as Tab traversal policy.

## Shortcuts, Actions, Intents

| API | Use when |
| --- | --- |
| `Shortcuts` + `Actions` + `Intent` | Key binding defined high in the tree; fulfillment may change with focus context |
| `CallbackShortcuts` | Simple key → callback; no Intent/Action separation needed |
| `FocusableActionDetector` | Combined focus + hover + shortcuts for a control |

Bindings only fire usefully when the focused subtree is under the matching
`Shortcuts` / `Actions` ancestors. Do not invent global app shortcuts unless
product requires them ([`design_system.md`](../design_system.md) form-factor
matrix: desktop/web input checks).

## FocusNode ownership (repo)

Official best practices that match this codebase:

- Create `FocusNode` in `State` (`initState` / `late final`); **never** allocate
  a new node every `build` (leaks + lost focus).
- Call `dispose()` on the same ownership path — enforced by
  `memory_state_controller_missing_dispose`.
- One node per focusable widget; set `debugLabel` for diagnostics.
- Prefer `focusNode.requestFocus()` over
  `FocusScope.of(context).requestFocus(focusNode)`.
- Prefer setting `onKeyEvent` on a `Focus` widget, not on a node already managed
  by `Focus` / `FocusScope` (widget rebuilds overwrite node callbacks).

There is always a primary focus somewhere; `unfocus()` moves it (scope or
previously focused child). Prefer focusing another node explicitly when you
care where it goes.

## Repo anchors

| Practice | Where |
| --- | --- |
| Dialog owns title/description `FocusNode`s + dispose | `todo_list_dialogs.dart` |
| Keyboard **Next** → `descriptionFocusNode.requestFocus()` | `todo_list_dialog_content.dart` + PlatformAdaptive `textInputAction` |
| Change note / tests | [`../changes/2026-09-08_todo_dialog_keyboard_focus_next.md`](../changes/2026-09-08_todo_dialog_keyboard_focus_next.md) |
| Dispose lint | [`../performance/memory_lints.md`](../performance/memory_lints.md) |
| Review checklist (rings / traversal) | [`../review/ui_ux_responsive_review.md`](../review/ui_ux_responsive_review.md) |

**Interview one-liner:** *Keystrokes follow primary focus on a sparse focus
tree (not hit-test); TextInput is the IME channel once an editable is focused;
dispose owned `FocusNode`s like any other controller.*
