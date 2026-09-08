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

## Project application

| Situation | Project evidence | Engineering decision |
| --- | --- | --- |
| Device-aware formatting | [`formatDeviceDateTime`](../../packages/app_shared_flutter/lib/src/date_time/date_time_formatting.dart) reads `MaterialLocalizations` and `MediaQuery` at the presentation call site; its test creates that scope with `Builder`. | Locale and 24-hour preference are ambient UI values, not domain inputs. |
| Initial Cubit work | [`CameraGalleryPage`](../../apps/mobile/lib/features/camera_gallery/presentation/pages/camera_gallery_page.dart) waits for the first frame and checks `mounted` before reading the scoped Cubit. | Avoids an inherited lookup during `initState` and avoids acting after disposal. |
| Delayed navigation | [`DeepLinkListener`](../../apps/mobile/lib/features/deeplink/presentation/deep_link_listener.dart) routes through [`NavigationUtils.safeGo`](../../apps/mobile/lib/app/utils/navigation.dart). | Navigation stays in presentation; the helper verifies the context remains mounted before `GoRouter.go`. |
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

For mechanically detectable lifecycle errors, run the repository's context and
async checks through the documented validation route. A passing guard does not
prove that the chosen ancestor scope is semantically correct; review the five
questions above for that decision.

## Sources

- Flutter API: [BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
- Flutter API: [dependOnInheritedWidgetOfExactType](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html)
- Flutter API: [InheritedWidget](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)
- Flutter architectural overview: [widget, element, and inherited-state model](https://docs.flutter.dev/resources/architectural-overview)
