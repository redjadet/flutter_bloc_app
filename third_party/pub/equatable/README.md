# Equatable 3.0 local shim

Path override of [equatable](https://pub.dev/packages/equatable) **3.0.0** that
re-exports a deprecated `EquatableMixin` typedef (`typedef EquatableMixin =
Equatable`) so transitive packages still on the removed mixin compile:

- `fl_chart` 1.2.0 ([imaNNeo/fl_chart#2120](https://github.com/imaNNeo/fl_chart/pull/2120))
- `firebase_auth_mocks` 0.15.x

## Remove when safe

Watch those package releases. When **both** ship without `EquatableMixin`
(and declare `equatable ^3`):

1. Delete this directory (`third_party/pub/equatable/`).
2. In root `pubspec.yaml`, drop the path override (use hosted `^3.0.0` or no
   override if the graph resolves).
3. `dart pub get`, then prove with `./bin/checklist` and charts / auth-mock
   tests.
4. Mark [`docs/engineering/workarounds.md`](../../../docs/engineering/workarounds.md)
   §5 **Resolved**.

Do not remove the shim early — hosted `equatable: ^3.0.0` alone breaks
`fl_chart` / `firebase_auth_mocks` compile.
