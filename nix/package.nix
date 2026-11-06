# Memrium built from this checkout: the compositor/shell, its apps and the secret service, wrapped so that the libraries
# that are loaded at run time (wayland, GL/Vulkan, xkb, libmpv, onnxruntime) are found on any NixOS.
{ lib, rustPlatform, pkg-config, makeWrapper
, wayland, libxkbcommon, libinput, libGL, mesa, libdrm, libgbm, udev, systemd, seatd, pixman, fontconfig, freetype
, xorg, vulkan-loader, mpv-unwrapped, xkeyboard_config, onnxruntime
, xwayland, wl-clipboard, ffmpeg, curl, glib, xdg-utils, wireplumber, networkmanager, bluez, dbus, pipewire, whisper-cpp
}:
let
  libs = [ wayland libxkbcommon libinput libGL mesa vulkan-loader mpv-unwrapped xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr ];
  # (pipewire for pw-record and whisper-cpp for whisper-cli: dictation, Super+H)
  tools = [ xwayland wl-clipboard ffmpeg curl glib xdg-utils wireplumber networkmanager bluez dbus fontconfig pipewire whisper-cpp ];
in
rustPlatform.buildRustPackage {
  pname = "memrium-de";
  version = "0.1.0";

  src = lib.cleanSource ../.;
  cargoLock.lockFile = ../Cargo.lock;

  # the screen-sharing portal links libpipewire through bindgen
  nativeBuildInputs = [ pkg-config makeWrapper rustPlatform.bindgenHook ];
  buildInputs = [ wayland libxkbcommon libinput libGL mesa libdrm libgbm udev systemd seatd pixman fontconfig freetype xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr vulkan-loader pipewire ];

  # the tests open GPU devices and the session bus
  doCheck = false;

  postInstall = ''
    install -Dm755 memrium/session/memrium-session $out/bin/memrium-session

    # the portal backend (file dialogs, screen sharing): xdg-desktop-portal finds it by its .portal file, the bus starts it on demand
    install -Dm644 memrium/session/portal/memrium.portal $out/share/xdg-desktop-portal/portals/memrium.portal
    mkdir -p $out/share/dbus-1/services
    sed "s|@BIN@|$out/bin|" memrium/session/portal/org.freedesktop.impl.portal.desktop.memrium.service.in \
      > $out/share/dbus-1/services/org.freedesktop.impl.portal.desktop.memrium.service

    # Files as the program that opens folders
    mkdir -p $out/share/applications
    cat > $out/share/applications/memrium-files.desktop <<DESKTOP
    [Desktop Entry]
    Name=Memrium Files
    Comment=Browse files and folders
    Exec=$out/bin/memrium_files %U
    Icon=system-file-manager
    Terminal=false
    Type=Application
    Categories=System;FileManager;
    MimeType=inode/directory;
    StartupWMClass=memrium-files
    DESKTOP
    mkdir -p $out/share/wayland-sessions
    cat > $out/share/wayland-sessions/memrium-de.desktop <<DESKTOP
    [Desktop Entry]
    Name=Memrium
    Comment=Configurable Wayland desktop
    Exec=$out/bin/memrium-session
    Type=Application
    DesktopNames=Memrium
    DESKTOP

    for f in $out/bin/memrium_*; do
      wrapProgram "$f" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs} \
        --suffix PATH : ${lib.makeBinPath tools} \
        --set-default XKB_CONFIG_ROOT ${xkeyboard_config}/etc/X11/xkb \
        --set-default MEMRIUM_LIBMPV ${mpv-unwrapped}/lib/libmpv.so.2 \
        --set-default MEMRIUM_ONNXRUNTIME ${onnxruntime}/lib/libonnxruntime.so
    done
  '';

  passthru.providedSessions = [ "memrium-de" ];

  meta = {
    description = "Memrium: a configurable Wayland desktop with a glass look, its own toolkit and apps";
    mainProgram = "memrium_compositor";
    platforms = lib.platforms.linux;
  };
}
