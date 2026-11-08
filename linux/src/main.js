import "./style.css";
import { invoke } from "@tauri-apps/api/core";
function report(error) {
  const message = error?.stack || error?.message || String(error);
  if (window.__TAURI_INTERNALS__)
    invoke("client_error", { message }).catch(() => {});
  console.error(message);
}
window.addEventListener("error", (event) =>
  report(event.error || event.message),
);
window.addEventListener("unhandledrejection", (event) => report(event.reason));
try {
  if (window.__AFTERGLOW_WALLPAPER__) await import("./wallpaper-view.js");
  else await import("./app.js");
} catch (error) {
  report(error);
  document.body.textContent =
    "Afterglow could not load its interface. Please restart the app.";
}
