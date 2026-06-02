part of 'genui_demo_content.dart';

class _GenUiMainSection extends StatelessWidget {
  const _GenUiMainSection();

  @override
  Widget build(final BuildContext context) {
    final viewState = context
        .selectState<
          GenUiDemoCubit,
          GenUiDemoState,
          ({
            String? errorMessage,
            List<String> surfaceIds,
            genui.A2uiMessageProcessor? hostHandle,
          })
        >(
          selector: (final state) => (
            errorMessage: state.maybeWhen(
              error: (final message, _, _, _) => message,
              orElse: () => null,
            ),
            surfaceIds: state.when(
              initial: () => const <String>[],
              loading: (final surfaceIds, _, _) => surfaceIds,
              ready: (final surfaceIds, _, _) => surfaceIds,
              error: (_, final surfaceIds, _, _) => surfaceIds,
            ),
            hostHandle: state.when(
              initial: () => null,
              loading: (_, _, final hostHandle) => hostHandle,
              ready: (_, final hostHandle, _) => hostHandle,
              error: (_, _, final hostHandle, _) => hostHandle,
            ),
          ),
        );

    final hostHandle = viewState.hostHandle;

    if (viewState.errorMessage case final message?) {
      return Column(
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
          if (hostHandle != null && viewState.surfaceIds.isNotEmpty)
            Expanded(
              child: _GenUiSurfacesList(
                surfaceIds: viewState.surfaceIds,
                hostHandle: hostHandle,
              ),
            ),
        ],
      );
    }

    if (hostHandle != null && viewState.surfaceIds.isNotEmpty) {
      return _GenUiSurfacesList(
        surfaceIds: viewState.surfaceIds,
        hostHandle: hostHandle,
      );
    }

    return Center(
      child: Text(
        context.l10n.genuiDemoHintText,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _GenUiSurfacesList extends StatelessWidget {
  const _GenUiSurfacesList({
    required this.surfaceIds,
    required this.hostHandle,
  });

  final List<String> surfaceIds;
  final genui.A2uiMessageProcessor hostHandle;

  @override
  Widget build(final BuildContext context) => ListView.builder(
    scrollCacheExtent: const ScrollCacheExtent.pixels(500),
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
}

class _GenUiInputRow extends StatelessWidget {
  const _GenUiInputRow({
    required this.textController,
    required this.onSendMessage,
  });

  final TextEditingController textController;
  final Future<void> Function() onSendMessage;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final isSending = context.selectState<GenUiDemoCubit, GenUiDemoState, bool>(
      selector: (final state) => state.when(
        initial: () => false,
        loading: (_, final isSending, _) => isSending,
        ready: (_, _, final isSending) => isSending,
        error: (_, _, _, final isSending) => isSending,
      ),
    );

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
                controller: textController,
                hintText: l10n.genuiDemoHintText,
                enabled: !isSending,
                onSubmitted: (_) => onSendMessage(),
              ),
            ),
            SizedBox(width: context.responsiveGapS),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: isSending ? null : onSendMessage,
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
