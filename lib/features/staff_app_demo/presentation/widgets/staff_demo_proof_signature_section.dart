import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:signature/signature.dart';

/// Signature capture for staff demo proof flow (theme-aware pad + export).
class StaffDemoProofSignatureSection extends StatefulWidget {
  const StaffDemoProofSignatureSection({super.key});

  @override
  State<StaffDemoProofSignatureSection> createState() =>
      _StaffDemoProofSignatureSectionState();
}

class _StaffDemoProofSignatureSectionState
    extends State<StaffDemoProofSignatureSection> {
  SignatureController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= SignatureController(
      exportBackgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _saveSignature(BuildContext context) async {
    final controller = _controller;
    if (controller == null) return;
    final bytes = await controller.toPngBytes();
    if (!context.mounted) return;
    if (bytes == null || bytes.isEmpty) {
      ErrorHandling.showErrorSnackBar(
        context,
        context.l10n.staffDemoProofSignatureSaveBefore,
      );
      return;
    }
    await context.cubit<StaffDemoProofCubit>().saveSignaturePngBytes(bytes);
    if (!context.mounted) return;
    ErrorHandling.showSuccessSnackBar(
      context,
      context.l10n.staffDemoProofSignatureSaveSuccess,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<StaffDemoProofCubit>().state;
    final sigLabel = state.signaturePath == null
        ? l10n.staffDemoProofSignatureNotSaved
        : l10n.staffDemoProofSignatureSaved;
    final controller = _controller;
    final colorScheme = Theme.of(context).colorScheme;

    if (controller == null) {
      return const Card(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.staffDemoProofSignatureLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(sigLabel),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Signature(
                controller: controller,
                backgroundColor: colorScheme.surface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                OutlinedButton(
                  onPressed: () {
                    controller.clear();
                    context.cubit<StaffDemoProofCubit>().setSignaturePath(null);
                  },
                  child: Text(l10n.staffDemoProofSignatureClear),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _saveSignature(context),
                  child: Text(l10n.staffDemoProofSignatureSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
