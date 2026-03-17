import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class FirebaseFunctionsTestPage extends StatefulWidget {
  const FirebaseFunctionsTestPage({super.key});

  @override
  State<FirebaseFunctionsTestPage> createState() =>
      _FirebaseFunctionsTestPageState();
}

class _FirebaseFunctionsTestPageState extends State<FirebaseFunctionsTestPage> {
  static const String _region = 'us-central1';
  bool _isCalling = false;
  String? _resultMessage;
  String? _errorMessage;
  String? _appCheckTokenPreview;

  bool get _isFirebaseReady => FirebaseBootstrapService.isFirebaseInitialized;

  Future<void> _refreshAppCheckToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken(true);
      if (!mounted) return;
      setState(() {
        _appCheckTokenPreview = token == null
            ? null
            : '${token.substring(0, token.length < 12 ? token.length : 12)}…';
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        // In monitoring-only mode (demo), App Check may be unavailable on
        // simulators. Avoid surfacing noisy errors in the UI.
        _appCheckTokenPreview = null;
      });
    }
  }

  Future<void> _callHelloWorld() async {
    if (_isCalling) return;
    if (!_isFirebaseReady) return;
    if (!mounted) return;

    setState(() {
      _isCalling = true;
      _errorMessage = null;
    });

    try {
      await _refreshAppCheckToken();
      final callable = FirebaseFunctions.instanceFor(
        region: _region,
      ).httpsCallable('helloWorld');
      final result = await callable.call<Map<String, dynamic>>();
      final data = result.data;
      final String? message = data['message'] as String?;
      if (!mounted) return;
      setState(() {
        _resultMessage = message ?? data.toString();
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        final detailsText = e.details == null ? '' : '\nDetails: ${e.details}';
        final tokenText = _appCheckTokenPreview == null
            ? ''
            : '\nAppCheck token: $_appCheckTokenPreview';
        _errorMessage = '${e.code}: ${e.message ?? ''}$detailsText$tokenText'
            .trim();
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCalling = false;
        });
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.firebaseFunctionsTestTitle,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isFirebaseReady)
              Text(
                l10n.firebaseUnavailableMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            const SizedBox(height: 12),
            if (_isFirebaseReady && _appCheckTokenPreview != null) ...[
              Text(
                'App Check token: $_appCheckTokenPreview',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: !_isFirebaseReady || _isCalling
                  ? null
                  : _callHelloWorld,
              child: _isCalling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.firebaseFunctionsCallButton),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.firebaseFunctionsResultLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(_errorMessage ?? _resultMessage ?? '-'),
          ],
        ),
      ),
    );
  }
}
