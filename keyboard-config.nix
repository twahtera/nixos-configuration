{ config, pkgs, ... }:

{
  # Configure entdas keyboard layout
  services.xserver.extraLayouts.entdas = {
    description = "Entdas keyboard layout";
    languages = [ "fi" ];
    symbolsFile = ./entdas.xkb;
  };
}
