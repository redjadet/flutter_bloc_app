part of 'staff_app_demo_content_page.dart';

class _ContentTile extends StatelessWidget {
  const _ContentTile({required this.item, super.key});

  final StaffDemoContentItem item;

  @override
  Widget build(final BuildContext context) {
    final icon = switch (item.type) {
      StaffDemoContentType.pdf => Icons.picture_as_pdf,
      StaffDemoContentType.video => Icons.play_circle,
    };

    return ListTile(
      leading: Icon(icon),
      title: Text(item.title),
      subtitle: Text(item.storagePath),
      onTap: () async {
        final cubit = context.cubit<StaffDemoContentCubit>();
        final url = await cubit.resolveUrl(item);
        if (!context.mounted) return;
        if (url == null) {
          ErrorHandling.showErrorSnackBar(
            context,
            context.l10n.staffDemoContentCouldNotLoadUrl,
          );
          return;
        }

        switch (item.type) {
          case StaffDemoContentType.pdf:
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _PdfViewerPage(
                  title: item.title,
                  url: url,
                ),
              ),
            );
          case StaffDemoContentType.video:
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _VideoViewerPage(
                  title: item.title,
                  url: url,
                ),
              ),
            );
        }
      },
    );
  }
}

class _PdfViewerPage extends StatelessWidget {
  const _PdfViewerPage({required this.title, required this.url});

  final String title;
  final Uri url;

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: PdfViewer.uri(url),
  );
}

class _VideoViewerPage extends StatefulWidget {
  const _VideoViewerPage({required this.title, required this.url});

  final String title;
  final Uri url;

  @override
  State<_VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<_VideoViewerPage> {
  late final VideoPlayerController _controller;
  Object? _initializationError;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(widget.url);
    unawaited(
      _controller
          .initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {});
            unawaited(_controller.play());
          })
          .catchError((final Object error) {
            if (!mounted) return;
            setState(() {
              _initializationError = error;
            });
          }),
    );
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Center(
      child: _initializationError != null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.staffDemoVideoPlayerError),
            )
          : _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const CircularProgressIndicator(),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _controller.value.isInitialized
          ? () async {
              try {
                if (_controller.value.isPlaying) {
                  await _controller.pause();
                } else {
                  await _controller.play();
                }
              } on Exception {
                // Ignore play/pause errors; the UI will remain responsive.
              }

              if (!mounted) return;
              setState(() {});
            }
          : null,
      child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
    ),
  );
}
