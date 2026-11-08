#!/usr/bin/env bash
set -euo pipefail
export WEBKIT_DISABLE_DMABUF_RENDERER=1
export LIBGL_ALWAYS_SOFTWARE=1
binary="$(realpath "$1")"
cd "$(dirname "$0")/.."
mkdir -p test-results
openbox >test-results/openbox.log 2>&1 &
wm_pid=$!
"$binary" >test-results/native.log 2>&1 &
app_pid=$!
cleanup(){
  status=$?
  if [[ "$status" != 0 ]]; then tail -80 test-results/native.log >&2; fi
  kill "$app_pid" "$wm_pid" 2>/dev/null || true
  sleep .2
  kill -KILL "$app_pid" "$wm_pid" 2>/dev/null || true
}
trap cleanup EXIT
for attempt in $(seq 1 60); do
  kill -0 "$app_pid"
  if xdotool search --name '^Afterglow$' >/dev/null 2>&1; then break; fi
  sleep .5
done
window="$(xdotool search --name '^Afterglow$' | head -1)"
xdotool windowactivate --sync "$window"
for attempt in $(seq 1 30); do
  if grep -q 'Afterglow UI ready' test-results/native.log; then break; fi
  sleep .5
done
grep -q 'Afterglow UI ready' test-results/native.log
sleep 1
# Start the explicit silent demo through a real mouse click in WebKitGTK.
xdotool mousemove --window "$window" 390 560 click 1
sleep 2
kill -0 "$app_pid"
xwininfo -id "$window" >test-results/native-window.txt
xdotool key --window "$window" ctrl+k
sleep 1
xdotool key --window "$window" Escape
"$binary" --action focus
sleep 1
xprop -id "$window" _NET_WM_STATE >test-results/focus-state.txt
grep -q '_NET_WM_STATE_FULLSCREEN' test-results/focus-state.txt
"$binary" --action focus
sleep 1
"$binary" --action desktop
sleep 2
wallpaper="$(xdotool search --name '^Afterglow Wallpaper$' | head -1)"
xprop -id "$wallpaper" _NET_WM_WINDOW_TYPE >test-results/desktop-state.txt
grep -q '_NET_WM_WINDOW_TYPE_DESKTOP' test-results/desktop-state.txt
"$binary" --action desktop
sleep 1
kill -0 "$app_pid"
if grep -Ei 'panicked at|error while loading shared libraries|symbol lookup error' test-results/native.log; then exit 1; fi
printf '%s\n' 'PASS native WebKitGTK launch, focus and X11 wallpaper window lifecycle'
