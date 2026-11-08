# Linux feature and release checks

This is the release gate for the Linux port. A checked implementation is not a claim that every distribution has passed testing. The macOS implementation stays in `Sources/Afterglow`.

| Mac behavior | Linux implementation | Release validation still required |
|---|---|---|
| Lyrics, recording matching, provider fallback/cache | Same Swift `AfterglowCore` via bounded JSON sidecar | Packaged helper on clean Linux, live provider checks |
| LRC/enhanced LRC/YAML/TXT imports, timing, alternatives | Shared parsers, per-recording local settings | Native file import and persistence checks |
| Spotify/Apple Music metadata and transport | MPRIS player discovery, selection and transport | Real Spotify; browser-specific Apple Music web behavior |
| Graph, glow, ribbons, word/line timing and chorus memory | Canvas/SVG renderer and deterministic arrangements | Native WebKitGTK visual comparison; long/RTL lyrics |
| Markers, emoji, colors, seven clocks and wallpaper copies | Local appearance controls and independent image copies | Fractional scaling and all clock/marker comparisons |
| Scenes, collections and color precedence | Atomic local library; saved scenes/colors/collections | Failure/recovery and native persistence lifecycle |
| Lyric cards and frozen map save/copy | PNG export, native dialog/image clipboard | Clipboard and desktop share targets |
| Focus/window/fullscreen and tray | Native Tauri window/tray and single-instance actions | Real KDE/GNOME tray availability and lifecycle |
| Desktop wallpaper | Separate renderer; X11 or compatible Wayland Layer Shell | Real X11/KDE/wlroots, monitor/workspace changes; GNOME Wayland integration remains absent |
| Player-only beat sync | PulseAudio selected sink-input monitor; portable FFT | Two simultaneous streams, routing changes, silence, Spotify process matching |
| Pause/hide/sleep/battery scheduling | Capture lifecycle, logind and UPower; lower battery frame rate | Physical suspend/wake, battery and thermal measurements; thermal-pressure parity remains absent |
| Global shortcuts | GlobalShortcuts portal plus desktop-bound single-instance actions | Portal allow/deny/rebind and unavailable-backend tests |
| Passive screenshot companion | Explicit capture-map action available | Passive desktop-specific screenshot hooks remain absent |

No stable Linux release or “full Mac parity” website claim until these checks are resolved. Do not substitute mixed system audio for unavailable player capture or imply that native Apple Music exists on Linux.
