FROM swift:6.2.1-noble
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  build-essential pkg-config curl ca-certificates git python3 python3-dbus python3-gi \
  libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev libgtk-layer-shell-dev \
  libdbus-1-dev libssl-dev libxdo-dev patchelf file xvfb dbus-x11 pulseaudio pulseaudio-utils \
  openbox x11-utils nodejs npm && rm -rf /var/lib/apt/lists/*
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
ENV PATH="/root/.cargo/bin:${PATH}" CARGO_BUILD_JOBS=2
WORKDIR /workspace
RUN architecture="$(dpkg --print-architecture)" && case "$architecture" in arm64) node_arch=arm64;; amd64) node_arch=x64;; *) exit 1;; esac \
  && curl -fsSL "https://nodejs.org/dist/v22.21.0/node-v22.21.0-linux-${node_arch}.tar.xz" | tar -xJ -C /usr/local --strip-components=1
RUN apt-get update && apt-get install -y --no-install-recommends xdotool && rm -rf /var/lib/apt/lists/*
