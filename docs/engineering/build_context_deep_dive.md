# BuildContext: location, scope, and lifetime

`BuildContext` is not a widget, dependency container, or general-purpose
service handle. It is Flutter's public interface for an `Element`: a handle to
one location in the live element tree. The location determines which ancestor
services and inherited values are visible.

This guide records the reasoning behind context-sensitive code in this
repository. It complements [BLoC Standards](../bloc_standards.md) and the
[context/async validation guide](../validation_scripts/guides_context_async.md);
those documents own state-management and automated-check details.

## The model

```text
Widget       immutable configuration; recreated freely by build
Element      persistent runtime node; connects configuration, parent, children,
             state, and render objects
BuildContext deliberately restricted view of that Element
```

`Theme.of(context)`, `MediaQuery.of(context)`, `Localizations.of(context)`,
and similar `of` APIs search from that element towards the root. They return
the *nearest* matching ancestor, not an app-global singleton. Therefore the
same API can resolve differently inside a local `Theme`, `Navigator`,
`MediaQuery`, or provider scope.

The distinction explains an otherwise surprising fact: the `context` received
by `build` belongs to the widget being built, not to widgets returned below it.
An ancestor inserted by that same `build` is not visible through the original
context. Request a descendant context with `Builder` when the new scope must be
read immediately.

```dart
Widget build(BuildContext context) {
  return Theme(
    data: localTheme,
    child: Builder(
      builder: (innerContext) => Text(
        'Scoped text',
        style: Theme.of(innerContext).textTheme.bodyMedium,
      ),
    ),
  );
}
```

Using `Theme.of(context)` in the `Text` expression above would read the theme
above this widget, not `localTheme`. `Builder` is a scope boundary tool; it is
not a rebuild-performance workaround.

## Inherited values are reactive dependencies

Most `of(context)` APIs ultimately use
`dependOnInheritedWidgetOfExactType`. The call has two effects:

1. Finds the nearest matching `InheritedWidget`.
2. Registers the current element as a dependent.

When the inherited value reports a relevant change, Flutter schedules that
dependent element to rebuild. This is why `Theme.of`, localization, and
provider-style APIs belong to a location-aware presentation layer. A value
captured from such a call should not be treated as permanently current beyond
the synchronous work that needs it.

For one-time ancestor inspection, use the API designed for that task rather
than creating an accidental rebuild dependency. Do not make a widget's `build`
output depend on a non-listening lookup: Flutter will have no dependency to
notify if that ancestor changes.

| Lookup | Returns | Registers dependency | Typical use |
| --- | --- | --- | --- |
| `dependOnInheritedWidgetOfExactType<T>()` | nearest `T` widget | yes | `of(context)` read in `build` / `didChangeDependencies` |
| `getInheritedWidgetOfExactType<T>()` | nearest `T` widget | no | one-off read in a callback (`maybeOf` without listening) |
| `getElementForInheritedWidgetOfExactType<T>()` | the `InheritedElement` | no | library code that needs the element (Provider's `read`) |

[`ResponsiveConfig.maybeDataOf`](../../packages/design_system/lib/src/responsive/responsive_config.dart)
is a deliberate non-listening read: `ScreenUtilInit` already marks the whole
tree for rebuild when the screen size changes, so a second dependency would only
duplicate rebuilds.

### Provider and BLoC placement

`context.read`, `context.watch`, and `context.select` (and the type-safe
`context.cubit` / `watchBloc` / `selectState` wrappers) are the same inherited
lookups with different dependency rules:

- `watch` / `select` register a dependency, so call them only inside `build`
  (or a builder callback). `select` asserts outside `build`.
- `read` does not listen. Use it in callbacks, listeners, `initState`, and
  post-frame work. Do not use it in `build` for values that must refresh.
  `tool/check_context_read_watch.sh` blocks `read`/`watch` misuse in
  presentation `build()`.
- A provider created in this `build` is below this `context`. Read it through
  a `Builder`, a child widget, or the `BlocBuilder`/`BlocListener` callback
  context.

## How `InheritedElement` propagates changes

The `InheritedWidget` is immutable configuration. Its `InheritedElement`
does the work: it is found by lookups, keeps the dependents, and notifies
them. Framework source
([`framework.dart`](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/framework.dart))
shows four mechanics that the summary APIs hide.

1. **Lookup is O(1), keyed by exact type.** Each `Element` holds
   `_inheritedElements`, a persistent hash map from `Type` to
   `InheritedElement` that it copies from its parent. An `InheritedElement`
   adds itself under `widget.runtimeType`. `dependOn…`, `get…Widget…` and
   `getElementFor…` are all one map read, not a walk up the tree. The inner
   entry overwrites the outer one, so the nearest ancestor wins. Because the
   key is the exact runtime type, a lookup for a base class does not find a
   subclass, and `Foo<int>` is a different key from `Foo<Object>`.
2. **Registration lasts until the element moves.** `dependOnInheritedElement`
   adds the ancestor to the dependent's `_dependencies` and calls
   `ancestor.updateDependencies(dependent, aspect)`. That records the
   dependent in the ancestor's `_dependents` map (`Element → aspect data`).
   Dependencies are not cleared on each build. They are dropped only when the
   element is deactivated, so an `of(context)` call inside an `if` keeps the
   subscription after the branch stops running.
3. **Notification is gated by `updateShouldNotify`.** When a parent rebuilds
   with a *new* widget instance, `InheritedElement.updated(oldWidget)` calls
   `updateShouldNotify(oldWidget)`. If it returns true, `notifyClients` calls
   `didChangeDependencies` on every dependent, which marks it dirty (a
   `State` gets `State.didChangeDependencies` before its next `build`). It is
   not called on first mount. It is also skipped when the parent passes the
   identical widget instance, because `updateChild` then leaves the element
   alone.
4. **Only dependents rebuild.** Notification does not rebuild the inherited
   widget's subtree. If `child` is the same instance (const, or a `child`
   passed into the parent), only the elements that registered rebuild. When
   `updateShouldNotify` returns false, dependents are not told. They keep the
   old value until something else rebuilds them.

### Writing a custom inherited scope

The repository has no hand-written `InheritedWidget`, `InheritedModel`, or
`InheritedNotifier` today. Scopes come from `BlocProvider`, `RepositoryProvider`,
`ResponsiveScope` (responsive_framework and ScreenUtil), and Mix's `MixScope`.
If you add one, this is the review checklist:

- **API shape.** Provide `maybeOf` (nullable) and `of` (calls `maybeOf`,
  then `assert(result != null, 'No Foo found in context')`). Return the data,
  not the widget, when callers only need the data. Keep the inherited widget
  private and put `of` on the public class when it is an implementation
  detail (this is how `Theme` works).
- **`updateShouldNotify` compares what dependents read, by value.**
  `return true` notifies on every parent rebuild. Comparing a mutable object
  by identity misses updates when it is mutated in place and passed again.
  Hold immutable values (Freezed or Equatable) or use `InheritedNotifier`.
- **No new collections or closures per build** when the comparison uses
  identity. Use `const`, memoise in the owning `State`, or compare with
  `listEquals` / `mapEquals`. `MixScope` rebuilds its token maps in
  `buildAppMixScope` but compares them with `mapEquals`, so dependents are
  notified only when a token value changes.
- **Aspects when dependents read disjoint parts.** `InheritedModel<T>` lets a
  dependent call `InheritedModel.inheritFrom<M>(context, aspect: …)`. After
  `updateShouldNotify` returns true, `updateShouldNotifyDependent(old,
  aspects)` decides per dependent. `MediaQuery` is an `InheritedModel`, which
  is why `MediaQuery.sizeOf` rebuilds less than `MediaQuery.of`. A dependent
  that passes no aspect is rebuilt on every change.
- **Listenables.** `InheritedNotifier<T extends Listenable>` notifies
  dependents when the notifier fires (coalesced to one rebuild per frame) or
  when the notifier instance changes. It removes its listener on unmount, but
  it does **not** dispose the notifier. The `State` that created the
  notifier disposes it.
- **Routes and overlays.** A dialog or route is not below the page, so it
  does not see the page's themes. `InheritedTheme.capture(from:, to:)` and
  `CapturedThemes.wrap` carry them across. Page-scoped Cubits are re-provided
  with `BlocProvider.value` (see below).
- **`didChangeDependencies` runs again after every notification.** Guard
  one-shot work with a flag and keep the method cheap. Do not cache an
  inherited value with `??=` there: the call still subscribes, but the field
  keeps the first value. Read it in `build`, or keep `null` to mean "follow
  the ambient value" (see the whiteboard row in [Project application](#project-application)).

### How Provider and flutter_bloc use it

- `InheritedProvider` is a `StatelessWidget` that builds a private
  `_InheritedProviderScope`. That inherited widget's `updateShouldNotify`
  always returns false. The element notifies dependents itself, through
  `markNeedsNotifyDependents`, when the value changes (the optional
  `updateShouldNotify` callback, default `!=`) or when `startListening`
  fires.
- `read` uses `getElementForInheritedWidgetOfExactType`, so no dependency.
  `watch` uses `dependOnInheritedElement`. `select` registers a selector
  closure as the *aspect*. On each notification the element runs every
  dependent's selectors and only notifies a dependent whose result differs
  under `DeepCollectionEquality`.
- `BlocProvider` wraps `InheritedProvider`. Its `startListening` subscribes
  to `bloc.stream` and calls `markNeedsNotifyDependents` on every emission.
  So `context.watch<Cubit>()` rebuilds on every emitted state, and
  `select` / `BlocSelector` filter. `BlocBase.emit` drops a state that is
  `==` to the current one (after the first emit). Value equality on state
  classes therefore decides whether an unchanged `copyWith` reaches the UI.
- `BlocProvider(create: …)` closes the bloc it created. `BlocProvider.value`
  does not.

## Lifetime: a context can become invalid

An element can be unmounted while a future, dialog, permission request, or
navigation transition is pending. After every async gap, verify the context
before using it for UI work:

```dart
await repository.save();
if (!context.mounted) return;
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
```

This is not merely lint appeasement. The action must target a still-live UI
location. Passing a context into a long-lived object, caching it, or using it
after `await` without that check couples work to a potentially dead element.

`initState` and `dispose` have a separate restriction: do not establish an
inherited dependency there. `initState` cannot be rerun when the dependency
changes, and the tree is no longer stable in `dispose`. Read reactive inherited
values in `build` or `didChangeDependencies`; use a post-frame callback only
when an initial imperative action is necessary, then re-check `mounted`.

Check the right flag. `State.mounted` only guards the State's own `context`.
A dialog builder context, `BlocListener` context, or `BuildContext` parameter
needs its own `context.mounted`. `use_build_context_synchronously` enforces
this after `await`; it does not treat `.then`, `Stream.listen`, `Timer`,
`addPostFrameCallback`, or `addListener` callbacks as async gaps. Those
callbacks need a manual `mounted` check before any context use. Run
`tool/check_context_mounted.sh` and `tool/check_setstate_mounted.sh` for the
mechanical cases.

Lifecycle rules:

- `initState`: no `dependOnInheritedWidgetOfExactType` (and no `Theme.of`,
  `MediaQuery.of`, `l10n`). A non-listening `read` is allowed.
- `didChangeDependencies`: first safe place for inherited reads outside
  `build`; it reruns when a dependency changes.
- `deactivate` / `dispose`: do not look up ancestors. Save the reference
  (for example `ScaffoldMessenger.of(context)`) in `didChangeDependencies`
  and use the saved object.

A State's `context` is the same `Element` for the State's whole life. What
changes is its position and its ancestors (for example after a `GlobalKey`
reparent). Different builder callbacks receive different contexts because they
are different elements.

## Overlays, routes, and environment lookups

- Dialogs, sheets, and new routes are inserted into the `Navigator`/`Overlay`,
  not below the page. They do not see page-scoped providers. Re-provide with
  `BlocProvider.value(value: cubit, child: ...)`, reading `cubit` from the page
  context before showing. `tool/check_modal_bloc_provider.sh` guards sheets.
- `showDialog` uses the root navigator by default (`useRootNavigator: true`).
  Inside a nested navigator (for example a `ShellRoute`), `Navigator.of(pageContext)`
  finds the shell navigator, not the dialog's. Close the dialog with its own
  builder context. [`ErrorHandling.hideLoadingDialog`](../../apps/mobile/lib/app/utils/error_handling.dart)
  pops with `useRootNavigator: true` for this reason.
- Use `ScaffoldMessenger.of(context)` for snackbars; it survives route changes
  and does not need a `Scaffold` ancestor. Use `Overlay.of(context, rootOverlay: true)`
  when an entry must sit above nested navigators.
- Prefer aspect lookups: `MediaQuery.sizeOf`, `paddingOf`, `viewInsetsOf`,
  `orientationOf`. `MediaQuery.of(context)` rebuilds on any `MediaQueryData`
  change (keyboard, text scale, padding); the aspect methods rebuild only when
  that value changes.

## Project application

| Situation | Project evidence | Engineering decision |
| --- | --- | --- |
| Device-aware formatting | [`formatDeviceDateTime`](../../packages/app_shared_flutter/lib/src/date_time/date_time_formatting.dart) reads `MaterialLocalizations` and `MediaQuery` at the presentation call site; its test creates that scope with `Builder`. | Locale and 24-hour preference are ambient UI values, not domain inputs. |
| Initial Cubit work | [`CameraGalleryPage`](../../apps/mobile/lib/features/camera_gallery/presentation/pages/camera_gallery_page.dart) waits for the first frame and checks `mounted` before reading the scoped Cubit. | Avoids an inherited lookup during `initState` and avoids acting after disposal. |
| Delayed navigation | [`DeepLinkListener`](../../apps/mobile/lib/features/deeplink/presentation/deep_link_listener.dart) routes through [`NavigationUtils.safeGo`](../../apps/mobile/lib/app/utils/navigation.dart). | Navigation stays in presentation; the helper verifies the context remains mounted before `GoRouter.go`. |
| Theme-following default | [`WhiteboardWidget`](../../apps/mobile/lib/features/example/presentation/widgets/whiteboard/whiteboard_widget.dart) keeps the pen color `null` until the user picks one and resolves `colorScheme.onSurface` on read. | A `didChangeDependencies` `??=` cache froze the first theme, so the default pen was dark on a dark canvas after a theme switch. |
| Notifier ownership | [`SocialFeedCommentComposer`](../../apps/mobile/lib/features/social_feed_demo/presentation/widgets/social_feed_comment_composer.dart) creates its `TextEditingController` in the sheet's `State` and disposes it there. | The sheet's `TextField` still listens during the exit animation, so the owner must be the widget that outlives it, not the static `show` call. |
| Business work | [BLoC Standards](../bloc_standards.md) keeps Cubits in presentation state management and domain/data free of Flutter UI imports. | A Cubit may emit state; a listener with a live context performs the snackbar, dialog, or navigation. |

These are ownership boundaries, not blanket rules against context parameters.
A short synchronous presentation helper can accept `BuildContext` when it
needs localized, themed, or layout data. Domain entities, repositories, data
sources, and long-lived Cubits must not retain it.

## Review questions

1. Which ancestor is this API expected to find, and is the supplied context
   actually below it?
2. Does this `of(context)` call intentionally create a rebuild dependency?
3. Is the use synchronous? If not, does a `mounted` check occur after the last
   async gap and before every context-dependent side effect?
4. Is UI scope leaking into a Cubit, domain type, repository, or service?
5. Could a nested `Navigator`, local theme, dialog, or provider intentionally
   change the nearest result? If yes, name that scope in the code or test.

6. If this adds an inherited scope, does `updateShouldNotify` compare the
   values dependents read, and who disposes any notifier it exposes?

For mechanically detectable lifecycle errors, run the repository's context and
async checks through the documented validation route. A passing guard does not
prove that the chosen ancestor scope is semantically correct; review the five
questions above for that decision.

## Sources

- Flutter API: [BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
- Flutter API: [dependOnInheritedWidgetOfExactType](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html)
- Flutter API: [InheritedWidget](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)
- Flutter architectural overview: [widget, element, and inherited-state model](https://docs.flutter.dev/resources/architectural-overview)
- Flutter API: [getInheritedWidgetOfExactType](https://api.flutter.dev/flutter/widgets/BuildContext/getInheritedWidgetOfExactType.html),
  [getElementForInheritedWidgetOfExactType](https://api.flutter.dev/flutter/widgets/BuildContext/getElementForInheritedWidgetOfExactType.html),
  [BuildContext.mounted](https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html)
- Flutter API: [State.initState](https://api.flutter.dev/flutter/widgets/State/initState.html),
  [State.didChangeDependencies](https://api.flutter.dev/flutter/widgets/State/didChangeDependencies.html),
  [State.deactivate](https://api.flutter.dev/flutter/widgets/State/deactivate.html)
- Flutter API: [showDialog](https://api.flutter.dev/flutter/material/showDialog.html),
  [ScaffoldMessenger](https://api.flutter.dev/flutter/material/ScaffoldMessenger-class.html),
  [Overlay.of](https://api.flutter.dev/flutter/widgets/Overlay/of.html),
  [MediaQuery](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)
- Flutter API: [InheritedElement](https://api.flutter.dev/flutter/widgets/InheritedElement-class.html),
  [InheritedModel](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html),
  [InheritedNotifier](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html),
  [InheritedTheme](https://api.flutter.dev/flutter/widgets/InheritedTheme-class.html)
- Flutter source: [`framework.dart`](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/framework.dart)
  (`_inheritedElements`, `InheritedElement`) and
  [`inherited_notifier.dart`](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/inherited_notifier.dart)
- Provider: [InheritedProvider](https://pub.dev/documentation/provider/latest/provider/InheritedProvider-class.html),
  [`inherited_provider.dart`](https://github.com/rrousselGit/provider/blob/master/packages/provider/lib/src/inherited_provider.dart) (`select`)
- flutter_bloc: [`bloc_provider.dart`](https://github.com/felangel/bloc/blob/master/packages/flutter_bloc/lib/src/bloc_provider.dart),
  [`bloc_base.dart`](https://github.com/felangel/bloc/blob/master/packages/bloc/lib/src/bloc_base.dart) (`emit`)
- Dart lint: [use_build_context_synchronously](https://dart.dev/tools/linter-rules/use_build_context_synchronously)
- Packages: [provider read/watch/select](https://pub.dev/packages/provider),
  [flutter_bloc concepts](https://bloclibrary.dev/flutter-bloc-concepts/)
