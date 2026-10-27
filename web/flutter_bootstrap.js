{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      document.getElementById('startup')?.remove();
    } catch (error) {
      console.error('AurumSentinel startup failed', error);
      window.showStartupError();
    }
  }
}).catch(function (error) {
  console.error('AurumSentinel loader failed', error);
  window.showStartupError();
});
