# NixOS module: adds the Memrium session to the login screen.
#   imports = [ memrium.nixosModules.default ];   programs.memrium.enable = true;
self: { config, lib, pkgs, ... }:
let cfg = config.programs.memrium; in
{
  options.programs.memrium = {
    enable = lib.mkEnableOption "the Memrium desktop session";
    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The Memrium build to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.displayManager.sessionPackages = [ cfg.package ];
    # a seat to take (logind), the GPU stack and the portals programs ask for
    security.polkit.enable = true;
    hardware.graphics.enable = true;
    services.dbus.enable = true;
    xdg.portal.enable = true;
    # file dialogs are Memrium Files; the rest of the portals stay with the GTK backend
    xdg.portal.extraPortals = [ cfg.package pkgs.xdg-desktop-portal-gtk ];
    xdg.portal.config.Memrium = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "memrium" ];
    };
    services.dbus.packages = [ cfg.package ];
  };
}
