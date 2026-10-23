{
  description = "Memrium: a configurable Wayland desktop";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (pkgs: rec {
        memrium = pkgs.callPackage ./nix/package.nix { };
        default = memrium;
      });
      # `nix run .` opens the desktop in a window inside the running session
      apps = forAll (pkgs: { default = { type = "app"; program = "${self.packages.${pkgs.system}.default}/bin/memrium_compositor"; }; });
      devShells = forAll (pkgs: { default = import ./shell.nix { inherit pkgs; }; });
      nixosModules.default = import ./nix/module.nix self;
    };
}
