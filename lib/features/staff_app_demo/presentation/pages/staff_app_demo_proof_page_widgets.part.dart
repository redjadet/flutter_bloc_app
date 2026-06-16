part of 'staff_app_demo_proof_page.dart';

class _ProofStatusBanner extends StatelessWidget {
  const _ProofStatusBanner({required this.state});

  final StaffDemoProofState state;

  /// Shared with [StaffAppDemoProofPage] so the banner can be pinned outside
  /// the scroll view only when it has content.
  static String? messageFor(
    final StaffDemoProofState state,
    final AppLocalizations l10n,
  ) => switch (state.status) {
    StaffDemoProofStatus.initial || StaffDemoProofStatus.editing => null,
    StaffDemoProofStatus.submitting => l10n.staffDemoSubmitting,
    StaffDemoProofStatus.success =>
      (state.lastProofId ?? '').trim().isEmpty
          ? l10n.staffDemoProofSubmittedEmpty
          : l10n.staffDemoProofSubmittedWithId(
              (state.lastProofId ?? '').trim(),
            ),
    StaffDemoProofStatus.offlineQueued => l10n.staffDemoProofOfflineQueued,
    StaffDemoProofStatus.error =>
      state.errorMessage ?? l10n.staffDemoProofFailed,
  };

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final String? message = messageFor(state, l10n);
    if (message == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final Color bg = switch (state.status) {
      StaffDemoProofStatus.success => colorScheme.primaryContainer,
      StaffDemoProofStatus.offlineQueued => colorScheme.tertiaryContainer,
      StaffDemoProofStatus.error => colorScheme.errorContainer,
      _ => colorScheme.surfaceContainerHighest,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection();

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoProofCubit>().state;
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.staffDemoProofPhotos,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (int i = 0; i < state.photoPaths.length; i++)
                  _PhotoChip(
                    path: state.photoPaths[i],
                    onRemove: () =>
                        context.cubit<StaffDemoProofCubit>().removePhotoAt(i),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () async {
                    final String? errorKey = await context
                        .cubit<StaffDemoProofCubit>()
                        .pickPhotoFromCamera();
                    if (!context.mounted) return;
                    if (errorKey != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            cameraGalleryErrorMessage(l10n, errorKey),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(l10n.staffDemoProofTakePhoto),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final String? errorKey = await context
                        .cubit<StaffDemoProofCubit>()
                        .pickPhotoFromGallery();
                    if (!context.mounted) return;
                    if (errorKey != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            cameraGalleryErrorMessage(l10n, errorKey),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: Text(l10n.staffDemoProofPickPhoto),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoChip extends StatelessWidget {
  const _PhotoChip({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(final BuildContext context) => InputChip(
    label: Text(path.split('/').last),
    onDeleted: onRemove,
  );
}

class _SubmitSection extends StatefulWidget {
  const _SubmitSection();

  @override
  State<_SubmitSection> createState() => _SubmitSectionState();
}

class _SubmitSectionState extends State<_SubmitSection> {
  final _shiftIdController = TextEditingController();
  String? _selectedSiteId;

  @override
  void dispose() {
    _shiftIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<StaffDemoProofCubit>().state;
    final bool busy = state.status == StaffDemoProofStatus.submitting;
    final sitesState = context.watch<StaffDemoSitesCubit>().state;
    final List<StaffDemoSite> sites = sitesState.sites;
    final effectiveSelectedSiteId =
        _selectedSiteId ?? (sites.isEmpty ? null : sites.first.siteId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.staffDemoProofSubmitProof,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(
                'staffDemo.proof.sitePicker.$effectiveSelectedSiteId',
              ),
              initialValue: effectiveSelectedSiteId,
              items: sites
                  .map(
                    (s) => DropdownMenuItem<String>(
                      value: s.siteId,
                      child: Text('${s.name} (${s.siteId})'),
                    ),
                  )
                  .toList(),
              onChanged: (busy || sites.isEmpty)
                  ? null
                  : (value) => setState(() => _selectedSiteId = value),
              decoration: InputDecoration(
                labelText: l10n.staffDemoSitePickerLabel,
                helperText: sitesState.status == StaffDemoSitesStatus.loading
                    ? l10n.staffDemoSitePickerLoading
                    : sitesState.status == StaffDemoSitesStatus.error
                    ? (sitesState.errorMessage ??
                          l10n.staffDemoSitePickerFailed)
                    : sites.isEmpty
                    ? l10n.staffDemoSitePickerEmpty
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _shiftIdController,
              decoration: InputDecoration(
                labelText: l10n.staffDemoProofShiftIdOptional,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: busy || effectiveSelectedSiteId == null
                    ? null
                    : () async {
                        final shiftId = _shiftIdController.text.trim();
                        await context.cubit<StaffDemoProofCubit>().submit(
                          siteId: effectiveSelectedSiteId,
                          shiftId: shiftId,
                        );
                      },
                child: Text(l10n.staffDemoProofSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
