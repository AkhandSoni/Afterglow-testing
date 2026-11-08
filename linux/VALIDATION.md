# Linux preview validation — 8 November 2026

The branch is a development preview. These results establish a working implementation, not full Mac parity or certification across Linux desktops.

Completed locally:

- Native macOS app builds; all 311 shared Swift checks pass on macOS and Ubuntu 24.04 ARM64, including the portable FFT checks.
- Swift sidecar protocol checks pass for demo, LRC/enhanced LRC/YAML/TXT and invalid requests. The release sidecar runs in a clean Ubuntu container without Swift installed; its remaining system dependency is curl, declared in the Debian package.
- Frontend domain checks pass for recording identity, monotonic timing/seek/pause, word gaps, collection color precedence, invalid-library preservation and excerpt limits.
- Headless Chrome interactions pass: explicit silent demo, seek/pause, scenes, collections, card/map PNG export, persistence, disconnect, and responsive controls. No page errors. Chrome does not establish WebKitGTK rendering parity.
- A real D-Bus MPRIS fixture passes discovery/metadata, transport, seeking, previous/next, stop and invalid commands on Linux.
- Two real PulseAudio sink inputs pass selected-stream isolation: the selected 1 kHz signal measures 0.20000 amplitude; the simultaneous 4 kHz stream is excluded (<0.0000001 measured amplitude).
- Native WebKitGTK UI boot, Focus Mode, and X11 wallpaper create/restore pass under Xvfb/Openbox. The test caught and fixed a GTK realization-order crash in click-through setup.
- Native Wayland Layer Shell wallpaper create/restore passes under headless Sway with a non-root user. An upstream GTK scale-factor warning appears during headless startup; physical display/fractional scaling checks remain outstanding.
- ARM64 `.deb` and AppImage packages build. The Debian package installs and passes the native launch/Focus/X11 wallpaper checks in a clean Ubuntu runtime with no Swift installed. The x86_64 Linux workflow [42502381472](https://github.com/medhansh-19/Afterglow/actions/runs/42502381472) passed shared-core/service checks, frontend checks, MPRIS, audio isolation, package builds, native WebKitGTK/X11 lifecycle and headless Wayland lifecycle; its artifact includes install instructions and checksums.
- The website is out of scope at the user’s request. Its local source tree and published version were restored to the exact pre-task website.

Remaining release work is listed in `PARITY.md`: GNOME Wayland wallpaper, passive screenshot companion, desktop-specific sharing, thermal pressure behavior, real player/desktop/portal tests, and physical suspend/battery/multiple-monitor validation. Global shortcut portal setup is implemented but approval/denial/rebinding has not been exercised against a real desktop portal.

The landing-page-oriented design checker reports structural failures on the desktop app (section rhythm, marketing metadata and template classes). It is not an appropriate pass/fail gate for the application window. Actual screenshots were inspected and the responsive functional checks above are the UI evidence; no claim of passing that marketing-page checker is made.
