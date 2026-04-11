// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/sites/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

class StaffAppDemoProofPage extends StatelessWidget {
  const StaffAppDemoProofPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoProofCubit>().state;
    return CommonPageLayout(
      title: 'Proof',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _ProofStatusBanner(state: state),
          const SizedBox(height: 16),
          const _PhotoSection(),
          const SizedBox(height: 16),
          const _SignatureSection(),
          const SizedBox(height: 16),
          const _SubmitSection(),
        ],
      ),
    );
  }
}

class _ProofStatusBanner extends StatelessWidget {
  const _ProofStatusBanner({required this.state});

  final StaffDemoProofState state;

  @override
  Widget build(final BuildContext context) {
    final String? message = switch (state.status) {
      StaffDemoProofStatus.initial || StaffDemoProofStatus.editing => null,
      StaffDemoProofStatus.submitting => 'Submitting…',
      StaffDemoProofStatus.success =>
        'Submitted proof ${state.lastProofId ?? ''}'.trim(),
      StaffDemoProofStatus.offlineQueued =>
        'Offline: queued for sync when online.',
      StaffDemoProofStatus.error => state.errorMessage ?? 'Failed.',
    };
    if (message == null) return const SizedBox.shrink();

    final Color bg = switch (state.status) {
      StaffDemoProofStatus.success => Colors.green.withValues(alpha: 0.12),
      StaffDemoProofStatus.offlineQueued => Colors.orange.withValues(
        alpha: 0.12,
      ),
      StaffDemoProofStatus.error => Colors.red.withValues(alpha: 0.12),
      _ => Colors.blue.withValues(alpha: 0.10),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Photos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    final picker = ImagePicker();
                    final XFile? file = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (!context.mounted) return;
                    if (file == null) return;
                    await context.cubit<StaffDemoProofCubit>().addPhotoFromPath(
                      file.path,
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take photo'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? file = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (!context.mounted) return;
                    if (file == null) return;
                    await context.cubit<StaffDemoProofCubit>().addPhotoFromPath(
                      file.path,
                    );
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick'),
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

class _SignatureSection extends StatefulWidget {
  const _SignatureSection();

  @override
  State<_SignatureSection> createState() => _SignatureSectionState();
}

class _SignatureSectionState extends State<_SignatureSection> {
  late final SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature(BuildContext context) async {
    final bytes = await _controller.toPngBytes();
    if (!context.mounted) return;
    if (bytes == null || bytes.isEmpty) {
      ErrorHandling.showErrorSnackBar(context, 'Please sign before saving.');
      return;
    }
    await context.cubit<StaffDemoProofCubit>().saveSignaturePngBytes(bytes);
    if (!context.mounted) return;
    ErrorHandling.showSuccessSnackBar(context, 'Signature saved.');
  }

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoProofCubit>().state;
    final sigLabel = state.signaturePath == null ? 'Not saved' : 'Saved';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Signature',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(sigLabel),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                OutlinedButton(
                  onPressed: () {
                    _controller.clear();
                    context.cubit<StaffDemoProofCubit>().setSignaturePath(null);
                  },
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _saveSignature(context),
                  child: const Text('Save signature'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
            const Text(
              'Submit proof',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                labelText: 'Site',
                helperText: sitesState.status == StaffDemoSitesStatus.loading
                    ? 'Loading sites...'
                    : sitesState.status == StaffDemoSitesStatus.error
                    ? (sitesState.errorMessage ?? 'Failed to load sites.')
                    : sites.isEmpty
                    ? 'No sites found in staffDemoSites.'
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _shiftIdController,
              decoration: const InputDecoration(
                labelText: 'Shift ID (optional)',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
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
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
