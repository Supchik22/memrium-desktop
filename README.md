# Memrium

A configurable Wayland desktop with a GPU "jelly glass" renderer, its own UI toolkit and a set of programs.
This repository assembles the whole desktop: every component lives in its own repository and is included here as a git
submodule, and one Cargo workspace builds them together.

| Repository | What it is |
| --- | --- |
| [memrium](https://github.com/Supchik22/memrium) | the shell: compositor, bars, dock, launcher, Settings, and the `memrium_de` library the programs share |
| [chebrium](https://github.com/Supchik22/chebrium) | the UI/UX toolkit (springs, software canvas, icons, text, widgets, Wayland runtime) |
| [memrium-secrets](https://github.com/Supchik22/memrium-secrets) | secret service (`org.freedesktop.secrets`), NetworkManager secret agent, password prompt |
| [chebrium-qtstyle](https://github.com/Supchik22/chebrium-qtstyle) | Qt widget style that follows the shell's look (CMake, not part of the Cargo build) |
| [memrium-files](https://github.com/Supchik22/memrium-files), [-view](https://github.com/Supchik22/memrium-view), [-player](https://github.com/Supchik22/memrium-player), [-term](https://github.com/Supchik22/memrium-term) | file manager, image viewer, media player (libmpv), terminal |
| [memrium-calc](https://github.com/Supchik22/memrium-calc), [-paint](https://github.com/Supchik22/memrium-paint), [-icons](https://github.com/Supchik22/memrium-icons), [-snake](https://github.com/Supchik22/memrium-snake) | calculator, bitmap editor, icon composer, a game |
| [memrium-monitor](https://github.com/Supchik22/memrium-monitor), [-archive](https://github.com/Supchik22/memrium-archive), [-convert](https://github.com/Supchik22/memrium-convert) | process monitor, archive manager, picture converter |

"Memrium" is a provisional name.

## Get the sources

```
git clone --recurse-submodules https://github.com/Supchik22/memrium-desktop
```

## Build and try it on NixOS

The Rust libraries come from `Cargo.lock`, so the first build needs the network and takes a while (about 12 minutes).

```
nix-build                          # ./result/bin/memrium_compositor, with every library and tool wrapped in
./result/bin/memrium_compositor    # inside a running Wayland desktop it opens as a window: nothing is installed
```

With flakes (the `submodules=1` part is needed, the components are submodules):

```
nix run "git+https://github.com/Supchik22/memrium-desktop?submodules=1"
```

To get it on the login screen:

```nix
# flake.nix of the system
inputs.memrium.url = "git+https://github.com/Supchik22/memrium-desktop?submodules=1";
# in the system's modules
imports = [ inputs.memrium.nixosModules.default ];
programs.memrium.enable = true;
```

then `sudo nixos-rebuild switch` and pick "Memrium" in the session list. Without flakes, add
`services.displayManager.sessionPackages = [ (pkgs.callPackage /path/to/memrium-desktop/nix/package.nix { }) ];`.
Qt programs only follow the shell's look when [chebrium-qtstyle](https://github.com/Supchik22/chebrium-qtstyle) is installed too.
Settings live in `~/.config/memrium`.

## Build without Nix

```
nix-shell            # or install: wayland, libxkbcommon, libinput, mesa, libdrm, udev, seatd, pixman, fontconfig, vulkan
cargo build --release
target/release/memrium_compositor        # nested in the current desktop
```

`memrium/session/memrium-session` starts it as a real session from a TTY or a display manager; see the
[memrium](https://github.com/Supchik22/memrium) README for the details, shortcuts and settings.

## Working on a component

Every component builds on its own (`cargo run` in its repository fetches Chebrium and the shell library from GitHub). In this
workspace the `[patch]` section of `Cargo.toml` points those dependencies at the checkouts here, so a change in `chebrium/`
is seen by every program at once. Commit inside the submodule, push it, then commit the new submodule revision here.

License: MIT.
