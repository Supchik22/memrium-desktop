{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ cargo rustc rustfmt clippy pkg-config foot rustPlatform.bindgenHook ];
  buildInputs = with pkgs; [
    wayland libxkbcommon libinput mesa libGL libdrm libgbm
    # screen sharing (the portal feeds a PipeWire stream)
    pipewire
    udev systemd seatd pixman fontconfig freetype
    xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
    vulkan-loader xkeyboard_config
    # libmpv, loaded at run time by memrium_player
    mpv-unwrapped
  ];
  XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/etc/X11/xkb";
  # the viewer's object cut-out and Live Text run their models on onnxruntime when it is there (loaded at run time).
  # 1.22 hangs when it is loaded (and the compositor loads it first thing): an older channel's one is left out
  MEMRIUM_ONNXRUNTIME = if pkgs.lib.versionAtLeast pkgs.onnxruntime.version "1.23" then "${pkgs.onnxruntime}/lib/libonnxruntime.so" else "";
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
    wayland libxkbcommon libGL mesa vulkan-loader libinput mpv-unwrapped
    xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
  ]);
}
