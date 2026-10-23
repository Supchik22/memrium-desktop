# nix-build            -> ./result/bin/memrium_compositor (run inside another Wayland session to try it in a window)
{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage ./nix/package.nix {}
