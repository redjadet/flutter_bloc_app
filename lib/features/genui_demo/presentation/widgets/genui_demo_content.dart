import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:genui/genui.dart' as genui;

class GenUiDemoContent extends StatefulWidget {
  const GenUiDemoContent({required this.state, super.key});

  final GenUiDemoState state;

  @override
  State<GenUiDemoContent> createState() => _GenUiDemoContentState();
}

class _GenUiDemoContentState extends State<GenUiDemoContent> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final cubit = context.cubit<GenUiDemoCubit>();
    await cubit.sendMessage(text);
  }

  @override
  Widget build(final BuildContext context) {
    final state = widget.state;

    return state.when(
      initial: () => const CommonLoadingWidget(),
      loading: (final surfaceIds, final isSending, final hostHandle) =>
          _buildContent(
            context: context,
            surfaceIds: surfaceIds,
            isSending: isSending,
            hostHandle: hostHandle,
          ),
      ready: (final surfaceIds, final hostHandle, final isSending) =>
          _buildContent(
            context: context,
            surfaceIds: surfaceIds,
            isSending: isSending,
            hostHandle: hostHandle,
          ),
      error:
          (
            final message,
            final surfaceIds,
            final hostHandle,
            final isSending,
          ) => Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (final context, final constraints) =>
                      SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: CommonErrorView(message: message),
                        ),
                      ),
                ),
              ),
              if (hostHandle != null && surfaceIds.isNotEmpty)
                Expanded(
                  child: _buildSurfacesList(
                    surfaceIds: surfaceIds,
                    hostHandle: hostHandle,
                  ),
                ),
              _buildInputRow(context: context, isSending: isSending),
            ],
          ),
    );
  }

  Widget _buildContent({
    required final BuildContext context,
    required final List<String> surfaceIds,
    required final bool isSending,
    required final genui.GenUiManager? hostHandle,
  }) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: hostHandle != null && surfaceIds.isNotEmpty
              ? _buildSurfacesList(
                  surfaceIds: surfaceIds,
                  hostHandle: hostHandle,
                )
              : Center(
                  child: Text(
                    l10n.genuiDemoHintText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
        ),
        _buildInputRow(context: context, isSending: isSending),
      ],
    );
  }

  Widget _buildSurfacesList({
    required final List<String> surfaceIds,
    required final genui.GenUiManager hostHandle,
  }) => ListView.builder(
    cacheExtent: 500,
    itemCount: surfaceIds.length,
    itemBuilder: (final context, final index) {
      final surfaceId = surfaceIds[index];
      return RepaintBoundary(
        key: ValueKey(surfaceId),
        child: genui.GenUiSurface(
          host: hostHandle,
          surfaceId: surfaceId,
        ),
      );
    },
  );

  Widget _buildInputRow({
    required final BuildContext context,
    required final bool isSending,
  }) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(context.responsiveGapM),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: PlatformAdaptive.textField(
                context: context,
                controller: _textController,
                hintText: l10n.genuiDemoHintText,
                enabled: !isSending,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: context.responsiveGapS),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: isSending ? null : _sendMessage,
              child: isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.onPrimary,
                        ),
                      ),
                    )
                  : Text(l10n.genuiDemoSendButton),
            ),
          ],
        ),
      ),
    );
  }
}
