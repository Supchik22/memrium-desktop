{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ cargo rustc rustfmt clippy pkg-config foot ];
  buildInputs = with pkgs; [
    wayland libxkbcommon libinput mesa libGL libdrm libgbm
    udev systemd seatd pixman fontconfig freetype
    xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
    vulkan-loader xkeyboard_config
    # libmpv, loaded at run time by memrium_player
    mpv-unwrapped
  ];
  XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/etc/X11/xkb";
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
    wayland libxkbcommon libGL mesa vulkan-loader libinput mpv-unwrapped
    xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
  ]);
}
