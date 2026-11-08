#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 linux/tests/mpris_fixture.py &
fixture_pid=$!
trap 'kill "$fixture_pid" 2>/dev/null || true' EXIT
for attempt in $(seq 1 30); do
  if dbus-send --session --print-reply --dest=org.mpris.MediaPlayer2.AfterglowFixture /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2 string:Identity >/dev/null 2>&1; then break; fi
  sleep .1
done
cargo test --manifest-path linux/src-tauri/Cargo.toml backend_mpris -- --ignored
