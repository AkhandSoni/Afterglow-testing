#!/usr/bin/env bash
# Run as an ordinary user inside dbus-run-session, with sway and a private XDG_RUNTIME_DIR.
set -euo pipefail
binary="$(realpath "$1")"
export WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1
export GDK_BACKEND=wayland WEBKIT_DISABLE_DMABUF_RENDERER=1 LIBGL_ALWAYS_SOFTWARE=1
out="${AFTERGLOW_WAYLAND_RESULTS:-/tmp/afterglow-wayland}"
mkdir -p "$out"
sway --unsupported-gpu -c "$(dirname "$0")/sway.conf" >"$out/sway.log" 2>&1 &
sway_pid=$!
app_pid=""
cleanup(){
  status=$?
  if [[ "$status" != 0 ]]; then tail -50 "$out/app.log" "$out/sway.log" >&2; fi
  if [[ -n "$app_pid" ]]; then kill "$app_pid" 2>/dev/null || true; fi
  kill "$sway_pid" 2>/dev/null || true
}
trap cleanup EXIT
for attempt in $(seq 1 60); do
  for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
    if [[ -S "$socket" && "$socket" != *.lock ]]; then export WAYLAND_DISPLAY="$(basename "$socket")"; break; fi
  done
  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then break; fi
  sleep .2
done
[[ -n "${WAYLAND_DISPLAY:-}" ]]
"$binary" --action desktop >"$out/app.log" 2>&1 &
app_pid=$!
for attempt in $(seq 1 60); do
  kill -0 "$app_pid"
  if grep -q 'Afterglow wallpaper ready: Wayland' "$out/app.log"; then break; fi
  sleep .5
done
grep -q 'Afterglow wallpaper ready: Wayland' "$out/app.log"
sleep 2
kill -0 "$app_pid"
"$binary" --action desktop
sleep 2
kill -0 "$app_pid"
if grep -E 'panicked at|Afterglow UI error' "$out/app.log"; then exit 1; fi
printf '%s\n' 'PASS native Wayland Layer Shell wallpaper lifecycle under headless Sway'
