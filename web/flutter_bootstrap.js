{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine();

      // Hide loading screen before running the app
      if (typeof hideLoading === 'function') {
        hideLoading();
      } else {
        var el = document.getElementById('loading');
        if (el) el.style.display = 'none';
      }

      await appRunner.runApp();
    } catch (e) {
      console.error('Engine initialization failed:', e);
      var err = document.getElementById('error-container');
      if (err) {
        err.style.display = 'flex';
        var detail = document.getElementById('error-detail');
        if (detail) {
          detail.style.display = 'block';
          detail.textContent = 'Engine Error: ' + (e.message || String(e));
        }
      }
    }
  }
});
