FROM swift:6.2.1-noble
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  build-essential pkg-config curl ca-certificates git python3 python3-dbus python3-gi \
  libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev libgtk-layer-shell-dev \
  libdbus-1-dev libssl-dev libxdo-dev patchelf file xvfb dbus-x11 pulseaudio pulseaudio-utils \
  openbox x11-utils nodejs npm && rm -rf /var/lib/apt/lists/*
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
ENV PATH="/root/.cargo/bin:${PATH}" CARGO_BUILD_JOBS=2
WORKDIR /workspace
