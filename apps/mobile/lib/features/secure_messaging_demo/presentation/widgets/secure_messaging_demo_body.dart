import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SecureMessagingDemoBody extends StatefulWidget {
  const SecureMessagingDemoBody({
    required this.state,
    required this.onPlaintextChanged,
    required this.onEncrypt,
    required this.onDecrypt,
    required this.onReset,
    this.failureMessage,
    super.key,
  });

  final SecureMessagingDemoState state;
  final ValueChanged<String> onPlaintextChanged;
  final VoidCallback onEncrypt;
  final VoidCallback onDecrypt;
  final VoidCallback onReset;
  final String? failureMessage;

  @override
  State<SecureMessagingDemoBody> createState() =>
      _SecureMessagingDemoBodyState();
}

class _SecureMessagingDemoBodyState extends State<SecureMessagingDemoBody> {
  static const double _maxContentWidth = 720;
  late final TextEditingController _plaintextController;

  @override
  void initState() {
    super.initState();
    _plaintextController = TextEditingController(
      text: widget.state.plaintext,
    );
  }

  @override
  void didUpdateWidget(covariant SecureMessagingDemoBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String next = widget.state.plaintext;
    if (_plaintextController.text != next &&
        (widget.state is SecureMessagingDemoReady ||
            widget.state is SecureMessagingDemoInitial ||
            widget.state is SecureMessagingDemoFailure &&
                (widget.state as SecureMessagingDemoFailure).payload == null)) {
      _plaintextController.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _plaintextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final SecureMessagingDemoState state = widget.state;
    final bool processing = state.isProcessing;
    final bool unavailable = state.isUnavailable;
    final String? ciphertext = state.payload?.base64Envelope;
    final String? recovered = state.recoveredPlaintext;
    final String? version = state.version;

    final List<Widget> column = <Widget>[
      Text(
        l10n.secureMessagingDemoSecurityWarning,
        key: const ValueKey('secure-messaging-demo-warning'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      SizedBox(height: context.responsiveGapM),
      if (unavailable)
        Text(
          l10n.secureMessagingDemoUnavailable,
          key: const ValueKey('secure-messaging-demo-unavailable'),
        )
      else ...[
        if (processing)
          const LinearProgressIndicator(
            key: ValueKey('secure-messaging-demo-processing'),
          ),
        if (version != null)
          Text(
            l10n.secureMessagingDemoVersionLabel(version),
            key: const ValueKey('secure-messaging-demo-version'),
          ),
        SizedBox(height: context.responsiveGapM),
        TextField(
          key: const ValueKey('secure-messaging-demo-plaintext'),
          enabled: !processing,
          controller: _plaintextController,
          onChanged: widget.onPlaintextChanged,
          decoration: InputDecoration(
            labelText: l10n.secureMessagingDemoPlaintextLabel,
          ),
          maxLines: 3,
        ),
        SizedBox(height: context.responsiveGapM),
        Wrap(
          spacing: context.responsiveGapS,
          runSpacing: context.responsiveGapS,
          children: <Widget>[
            FilledButton(
              key: const ValueKey('secure-messaging-demo-encrypt'),
              onPressed: processing ? null : widget.onEncrypt,
              child: Text(l10n.secureMessagingDemoEncryptButton),
            ),
            FilledButton.tonal(
              key: const ValueKey('secure-messaging-demo-decrypt'),
              onPressed: processing || ciphertext == null
                  ? null
                  : widget.onDecrypt,
              child: Text(l10n.secureMessagingDemoDecryptButton),
            ),
            OutlinedButton(
              key: const ValueKey('secure-messaging-demo-reset'),
              onPressed: processing ? null : widget.onReset,
              child: Text(l10n.secureMessagingDemoResetButton),
            ),
          ],
        ),
        if (ciphertext != null) ...[
          SizedBox(height: context.responsiveGapM),
          SelectableText(
            ciphertext,
            key: const ValueKey('secure-messaging-demo-ciphertext'),
          ),
        ],
        if (recovered != null) ...[
          SizedBox(height: context.responsiveGapM),
          Text(
            l10n.secureMessagingDemoSuccessLabel,
            key: const ValueKey('secure-messaging-demo-success'),
          ),
          Text(
            recovered,
            key: const ValueKey('secure-messaging-demo-recovered'),
          ),
        ],
        if (widget.failureMessage case final String failureMessage) ...[
          SizedBox(height: context.responsiveGapM),
          Text(
            failureMessage,
            key: const ValueKey('secure-messaging-demo-failure'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    ];

    return ListView(
      padding: EdgeInsets.all(context.responsiveGapM),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: column,
            ),
          ),
        ),
      ],
    );
  }
}
