import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_failure.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_cubit.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_state.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/widgets/secure_messaging_demo_body.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SecureMessagingDemoPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.secureMessagingDemoTitle,
      body: BlocBuilder<SecureMessagingDemoCubit, SecureMessagingDemoState>(
        builder: (context, state) {
          return SecureMessagingDemoBody(
            state: state,
            failureMessage: _failureMessage(l10n, state),
            onPlaintextChanged: context
                .read<SecureMessagingDemoCubit>()
                .updatePlaintext,
            onEncrypt: context.read<SecureMessagingDemoCubit>().encrypt,
            onDecrypt: context.read<SecureMessagingDemoCubit>().decrypt,
            onReset: context.read<SecureMessagingDemoCubit>().reset,
          );
        },
      ),
    );
  }

  String? _failureMessage(
    AppLocalizations l10n,
    SecureMessagingDemoState state,
  ) {
    if (state is! SecureMessagingDemoFailure) {
      return null;
    }
    return switch (state.failure) {
      SecureCoreInvalidInputFailure() =>
        l10n.secureMessagingDemoErrorInvalidInput,
      SecureCoreMalformedCiphertextFailure() =>
        l10n.secureMessagingDemoErrorMalformed,
      SecureCoreAuthenticationFailedFailure() =>
        l10n.secureMessagingDemoErrorAuthFailed,
      SecureCoreUnsupportedVersionFailure() =>
        l10n.secureMessagingDemoErrorUnsupportedVersion,
      SecureCoreUnavailableFailure() => l10n.secureMessagingDemoUnavailable,
      SecureCoreInternalFailure() => l10n.secureMessagingDemoErrorInternal,
      SecureCoreMismatchFailure() => l10n.secureMessagingDemoErrorMismatch,
    };
  }
}
