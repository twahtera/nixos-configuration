{ config, pkgs, ... }:

{
  # Configure entdas keyboard layout
  services.xserver.extraLayouts.entdas = {
    description = "Entdas keyboard layout";
    languages = [ "fi" ];
    symbolsFile = ./entdas.xkb;
  };

  # Common configuration options for all systems
  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
