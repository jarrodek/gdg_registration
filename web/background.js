
chrome.app.runtime.onLaunched.addListener(function(launchData) {
  chrome.app.window.create('gdg_registration.html', {
    'id': '_mainWindow', 'bounds': {'width': 800, 'height': 600 }
  });
});
