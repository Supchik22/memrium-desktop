# Memrium built from this checkout: the compositor/shell, its apps and the secret service, wrapped so that the libraries
# that are loaded at run time (wayland, GL/Vulkan, xkb, libmpv) are found on any NixOS.
{ lib, rustPlatform, pkg-config, makeWrapper
, wayland, libxkbcommon, libinput, libGL, mesa, libdrm, libgbm, udev, systemd, seatd, pixman, fontconfig, freetype
, xorg, vulkan-loader, mpv-unwrapped, xkeyboard_config
, xwayland, wl-clipboard, ffmpeg, curl, glib, xdg-utils, wireplumber, networkmanager, bluez, dbus
}:
let
  libs = [ wayland libxkbcommon libinput libGL mesa vulkan-loader mpv-unwrapped xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr ];
  tools = [ xwayland wl-clipboard ffmpeg curl glib xdg-utils wireplumber networkmanager bluez dbus fontconfig ];
in
rustPlatform.buildRustPackage {
  pname = "memrium-de";
  version = "0.1.0";

  src = lib.cleanSource ../.;
  cargoLock.lockFile = ../Cargo.lock;

  nativeBuildInputs = [ pkg-config makeWrapper ];
  buildInputs = [ wayland libxkbcommon libinput libGL mesa libdrm libgbm udev systemd seatd pixman fontconfig freetype xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr vulkan-loader ];

  # the tests open GPU devices and the session bus
  doCheck = false;

  postInstall = ''
    install -Dm755 memrium/session/memrium-session $out/bin/memrium-session
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
        --set-default MEMRIUM_LIBMPV ${mpv-unwrapped}/lib/libmpv.so.2
    done
  '';

  passthru.providedSessions = [ "memrium-de" ];

  meta = {
    description = "Memrium: a configurable Wayland desktop with a glass look, its own toolkit and apps";
    mainProgram = "memrium_compositor";
    platforms = lib.platforms.linux;
  };
}
