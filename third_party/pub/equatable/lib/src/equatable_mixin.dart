import 'package:equatable/src/equatable.dart';

/// Deprecated compatibility alias for packages still using `EquatableMixin`
/// (e.g. `fl_chart` 1.2.0, `firebase_auth_mocks` 0.15.x).
///
/// Equatable 3.0 removed [EquatableMixin]; use `with Equatable` instead.
/// This typedef keeps transitive dependencies compiling until they migrate.
@Deprecated('Use Equatable as a mixin instead')
typedef EquatableMixin = Equatable;
