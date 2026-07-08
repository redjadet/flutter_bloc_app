part of 'app_routes.dart';

const String _authUpgradeQueryKey = 'upgrade';
const String _authUpgradeQueryValue = 'true';

/// Auth route for anonymous users upgrading to a full account.
String _appRoutesAuthUpgradePath({final String? redirect}) {
  final Map<String, String> queryParameters = <String, String>{
    _authUpgradeQueryKey: _authUpgradeQueryValue,
  };
  if (redirect case final String redirectPath
      when _appRoutesIsSafeRedirectPath(redirectPath)) {
    queryParameters['redirect'] = redirectPath;
  }
  return Uri(
    path: AppRoutes.authPath,
    queryParameters: queryParameters,
  ).toString();
}

/// Returns true if [path] is safe for post-login redirect (local path only).
/// Rejects null, empty, protocol-relative (//), and external URLs.
bool _appRoutesIsSafeRedirectPath(final String? path) {
  if (path == null || path.isEmpty) return false;
  if (path.trim() != path) return false;
  if (!path.startsWith('/')) return false;
  if (path.startsWith('//')) return false;
  // Reject scheme tricks and external URL fragments in a local path.
  if (path.contains(':') || path.contains(r'\') || path.contains('@')) {
    return false;
  }
  return true;
}
