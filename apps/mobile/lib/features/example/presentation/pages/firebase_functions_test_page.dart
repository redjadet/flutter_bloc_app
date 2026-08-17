import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class FirebaseFunctionsTestPage extends StatefulWidget {
  const FirebaseFunctionsTestPage({
    required this.isFirebaseReady,
    this.isAuthenticated = false,
    this.functions,
    super.key,
  });

  /// Resolved at router from Firebase bootstrap readiness.
  final bool isFirebaseReady;

  /// True when FirebaseAuth has a current user (including anonymous).
  final bool isAuthenticated;

  /// Optional injectable Functions instance for tests.
  final FirebaseFunctions? functions;

  @override
  State<FirebaseFunctionsTestPage> createState() =>
      _FirebaseFunctionsTestPageState();
}

class _FirebaseFunctionsTestPageState extends State<FirebaseFunctionsTestPage> {
  static const String _region = 'us-central1';
  bool _isCalling = false;
  String? _resultMessage;
  String? _errorMessage;

  bool get _isFirebaseReady => widget.isFirebaseReady;
  bool get _isAuthenticated => widget.isAuthenticated;

  FirebaseFunctions get _functions =>
      widget.functions ?? FirebaseFunctions.instanceFor(region: _region);

  Future<void> _callHelloWorld() async {
    if (_isCalling || !_isFirebaseReady || !mounted) {
      return;
    }

    setState(() {
      _isCalling = true;
      _errorMessage = null;
      _resultMessage = null;
    });

    try {
      final HttpsCallableResult<Map<String, dynamic>> result = await _functions
          .httpsCallable('helloWorld')
          .call<Map<String, dynamic>>();
      final Map<String, dynamic> data = result.data;
      final String? message = data['message'] as String?;
      if (!mounted) {
        return;
      }
      setState(() {
        _resultMessage = message ?? '-';
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _safeFunctionsError(e, context.l10n);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = context.l10n.firebaseFunctionsGenericError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCalling = false;
        });
      }
    }
  }

  Future<void> _callHfReadToken() async {
    if (_isCalling || !_isFirebaseReady || !_isAuthenticated || !mounted) {
      return;
    }

    setState(() {
      _isCalling = true;
      _errorMessage = null;
      _resultMessage = null;
    });

    try {
      final HttpsCallableResult<dynamic> result = await _functions
          .httpsCallable('issueRenderChatDemoHfReadToken')
          .call<dynamic>();
      final Object? data = result.data;
      final String? token = _extractToken(data);
      if (!mounted) {
        return;
      }
      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = context.l10n.firebaseFunctionsMalformedResponse;
        });
        return;
      }
      final int length = token.length;
      setState(() {
        _resultMessage = 'token_present=true length=$length';
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _safeFunctionsError(e, context.l10n);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = context.l10n.firebaseFunctionsGenericError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCalling = false;
        });
      }
    }
  }

  static String? _extractToken(Object? data) {
    if (data is! Map) {
      return null;
    }
    final Object? primary = data['hf_read_token'];
    if (primary is String && primary.trim().isNotEmpty) {
      return primary.trim();
    }
    final Object? legacy = data['token'];
    return legacy is String && legacy.trim().isNotEmpty ? legacy.trim() : null;
  }

  static String _safeFunctionsError(
    FirebaseFunctionsException exception,
    AppLocalizations l10n,
  ) {
    return '${exception.code}: ${l10n.firebaseFunctionsSafeError}';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool helloEnabled = _isFirebaseReady && !_isCalling;
    final bool tokenEnabled =
        _isFirebaseReady && _isAuthenticated && !_isCalling;

    return CommonPageLayout(
      title: l10n.firebaseFunctionsTestTitle,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!_isFirebaseReady)
              Text(
                l10n.firebaseUnavailableMessage,
                key: const ValueKey('firebase-functions-unavailable'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            if (_isFirebaseReady && !_isAuthenticated) ...<Widget>[
              Text(
                l10n.firebaseFunctionsAuthRequired,
                key: const ValueKey('firebase-functions-auth-required'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              key: const ValueKey('firebase-functions-hello-button'),
              onPressed: helloEnabled ? _callHelloWorld : null,
              child: _isCalling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.firebaseFunctionsCallButton),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('firebase-functions-token-button'),
              onPressed: tokenEnabled ? _callHfReadToken : null,
              child: Text(l10n.firebaseFunctionsTokenCallButton),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.firebaseFunctionsResultLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              _errorMessage ?? _resultMessage ?? '-',
              key: const ValueKey('firebase-functions-result'),
            ),
          ],
        ),
      ),
    );
  }
}
