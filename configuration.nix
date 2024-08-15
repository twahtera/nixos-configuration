{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-fb066378-3578-4e0c-8637-6fa88cf9db70".device = "/dev/disk/by-uuid/fb066378-3578-4e0c-8637-6fa88cf9db70";
  networking.hostName = "seki";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

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

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  #services.desktopManager.plasma6.enable = true;
  #services.xserver.displayManager.lightdm = {
  #  enable = true;
  #  greeters.slick.enable = true;
  #};
  
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "fi";
    xkbVariant = "";

    videoDrivers = [ "modesetting" ];

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      enableConfiguredRecompile = true;
    };
  };

  # Configure console keymap
  console.keyMap = "fi";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # laptop stuff
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.twah = {
    isNormalUser = true;
    description = "Tuukka Wahtera";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
      kdePackages.kate
      git
      wget
      curl
      htop
      rxvt-unicode
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ ];
  services.openssh.enable = true;

  programs.light.enable = true; # Needed for the /run/wrappers/bin/light SUId wrapper.
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/wrappers/bin/light -A 10"; }
      { keys = [ 225]; events = [ "key" ]; command = "/run/wrappers/bin/light -U 10"; }
    ];
  };
  
  system.stateVersion = "24.05"; # Did you read the comment?

}
