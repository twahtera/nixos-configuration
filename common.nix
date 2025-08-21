{ config, pkgs, ... }:

{
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config = {
    allowUnfree = true;
  };
  
  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  programs.fish.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  console.keyMap = "fi";
  
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint ];
    };

    fstrim.enable = true;

    xserver.displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        cursorTheme.name = "capitaine-cursors";
        cursorTheme.size = 32;
      };
    };
    
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    xserver = {
      enable = true;

      # Configure entdas keyboard layout
      xkb = {
        layout = "entdas";

        extraLayouts.entdas = {
          description = "Entdas keyboard layout";
          languages = [ "fi" ];
          symbolsFile = ./entdas.xkb;
        };
      };
      windowManager.xmonad.enable = true;
      windowManager.xmonad.enableContribAndExtras = true;

    };
  };

  hardware = {

  };

  virtualisation.docker.enable = true;
  security.rtkit.enable = true;

  environment = {
    systemPackages = with pkgs; [ capitaine-cursors ];
  };

}
