{{flutter_js}}
{{flutter_build_config}}

(function () {
  const loading = document.getElementById('flutter-loading');
  const status = document.getElementById('flutter-loading-status');

  function setStatus(text) {
    if (status) {
      status.textContent = text;
    }
  }

  function removeLoading() {
    if (loading) {
      loading.remove();
    }
  }

  // HTML splash covers download + engine init; remove only once Flutter paints.
  // Slow networks must keep a visible loading state rather than regress to a
  // blank page after an arbitrary timeout.
  window.addEventListener('flutter-first-frame', removeLoading, { once: true });
  window.setTimeout(() => setStatus('Still loading…'), 30000);

  setStatus('Loading app…');
  _flutter.loader.load({
    onEntrypointLoaded: async function (engineInitializer) {
      setStatus('Starting engine…');
      // Wasm builds pick skwasm when supported; otherwise CanvasKit.
      // canvasKitVariant auto chooses the smaller Chromium build when possible.
      const appRunner = await engineInitializer.initializeEngine({
        canvasKitVariant: 'auto',
      });
      setStatus('Launching…');
      await appRunner.runApp();
    },
  });
})();
