#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
triple="${1:-$(rustc -vV | sed -n 's/^host: //p')}"
mkdir -p linux/src-tauri/binaries
swift build -c release --product afterglow-lyrics --static-swift-stdlib
cp "$(swift build -c release --show-bin-path)/afterglow-lyrics" "linux/src-tauri/binaries/afterglow-lyrics-$triple"
if [[ "$triple" == *linux* ]]; then
  binary="linux/src-tauri/binaries/afterglow-lyrics-$triple"
  mkdir -p linux/src-tauri/runtime
  # Swift/Foundation libraries may remain dynamic despite --static-swift-stdlib.
  # Keep them private to the sidecar; do not change the host's linker configuration.
  ldd "$binary" | awk '/=> \/.*swift\// {print $3}' | while IFS= read -r library; do
    cp -L "$library" linux/src-tauri/runtime/
  done
  LD_LIBRARY_PATH="$PWD/linux/src-tauri/runtime" "$binary" <<< '{"command":"demo"}' | python3 -c 'import json,sys; assert json.load(sys.stdin)["document"]["lines"]'
fi
