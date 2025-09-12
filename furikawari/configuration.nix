# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-7ffe902e-5bf4-4d4e-a465-7d531c3c71e2".device = "/dev/disk/by-uuid/7ffe902e-5bf4-4d4e-a465-7d531c3c71e2";

  boot.kernelModules = [ "amdgpu" ];
  networking.hostName = "furikawari"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  # powerManagement.powertop.enable = true;
# Enable networking
  networking.networkmanager.enable = true;
  programs.kdeconnect.enable = true;
  programs.fish.enable = true;

  services.xserver = {
    deviceSection = ''Option "TearFree" "true"''; # For amdgpu.
  };
  
  # Enable the GNOME Desktop Environment.


  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;

  services.pipewire = {
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.twah = {
    isNormalUser = true;
    description = "Tuukka Wahtera";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    shell = pkgs.fish;
    packages = with pkgs; [
	    git
      rxvt-unicode
    #  thunderbird
    ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.syncthing = {
    enable = true;
    user = "twah";
    group = "users";
    openDefaultPorts = true;
    configDir = "/home/twah/.config/syncthing";
    dataDir = "/home/twah/.config/syncthing/db";
  };

  # Install firefox.
  programs.firefox.enable = true;

  nix.settings.trusted-users = ["root" "twah"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.fwupd.enable = true;

  services.physlock = {
    enable = true;
    muteKernelMessages = true;
    allowAnyUser = true;
  };
  system.stateVersion = "24.05"; # Did you read the comment?

}
