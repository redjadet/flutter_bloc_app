part of 'online_therapy_demo_shell_page.dart';

class _TopControls extends StatelessWidget {
  const _TopControls();

  @override
  Widget build(final BuildContext context) {
    final cubit = context.cubit<OnlineTherapyDemoSessionCubit>();
    final controls = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          ({
            TherapyRole role,
            OnlineTherapyNetworkMode networkMode,
            bool isBusy,
            TherapyUser? user,
          })
        >(
          selector: (final state) => (
            role: state.role,
            networkMode: state.networkMode,
            isBusy: state.isBusy,
            user: state.user,
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: DropdownButton<TherapyRole>(
              isExpanded: true,
              value: controls.role,
              onChanged: controls.isBusy
                  ? null
                  : (final v) {
                      if (v == null) return;
                      // check-ignore: side_effects_build - user gesture (dropdown).
                      unawaited(cubit.setRole(v));
                    },
              items: TherapyRole.values
                  .map(
                    (r) => DropdownMenuItem<TherapyRole>(
                      value: r,
                      child: Text(
                        'Role: ${r.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: DropdownButton<OnlineTherapyNetworkMode>(
              isExpanded: true,
              value: controls.networkMode,
              onChanged: controls.isBusy
                  ? null
                  : (final v) => v == null ? null : cubit.setNetworkMode(v),
              items: OnlineTherapyNetworkMode.values
                  .map(
                    (m) => DropdownMenuItem<OnlineTherapyNetworkMode>(
                      value: m,
                      child: Text(
                        'Network: ${m.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          if (controls.user != null)
            Text(
              'User: ${controls.user?.displayName} (${controls.user?.maskedEmail})',
            ),
          if (controls.user != null)
            ElevatedButton(
              onPressed: controls.isBusy ? null : () => cubit.logout(),
              child: Text(context.l10n.logoutButtonLabel),
            ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatefulWidget {
  const _LoginPanel();

  @override
  State<_LoginPanel> createState() => _LoginPanelState();
}

class _LoginPanelState extends State<_LoginPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final emailDraft =
          context.cubit<OnlineTherapyDemoSessionCubit>().state.emailDraft ?? '';
      if (_controller.text != emailDraft) {
        _controller.text = emailDraft;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final viewState = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          ({String? emailDraft, bool isBusy})
        >(
          selector: (final state) => (
            emailDraft: state.emailDraft,
            isBusy: state.isBusy,
          ),
        );
    final cubit = context.cubit<OnlineTherapyDemoSessionCubit>();

    final nextText = viewState.emailDraft ?? '';
    if (_controller.text != nextText) {
      _controller.value = _controller.value.copyWith(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Login (demo)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: !viewState.isBusy,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'demo@example.com',
              ),
              onChanged: cubit.setEmailDraft,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewState.isBusy ? null : () => cubit.login(),
                child: Text(viewState.isBusy ? 'Signing in…' : 'Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
