# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./scarlett2i2-pulse.nix
      ../nix-ld.nix
    ];

  boot.loader.grub = {
    configurationLimit = 8;
    useOSProber = true;
  };

  swapDevices = [{
    device = "/dev/disk/by-id/wwn-0x500a0751e6ab93d2-part2";
  }];

  powerManagement.cpuFreqGovernor = "performance";
    
  # fileSystems."/home".device = "/dev/disk/by-label/home";
  fileSystems."/home".device = "/dev/disk/by-uuid/fba97cf9-9f6e-41a3-95ee-954da238fa5d";
  # fileSystems."/vm".device = "/dev/disk/by-label/win";
  boot.loader.grub.device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21JNXAGB12956A";


  boot.kernelParams = ["nordrand"];
  # "video=DisplayPort-1:3840x2160@240"
  #boot.kernelPackages = pkgs.linuxPackages-rt;
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  boot.kernelModules = [
    "amdgpu"
    "v4l2loopback"
  ];

  boot.extraModprobeConfig = ''
    options v4l2loopback max_buffers=2 devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];


  programs.virt-manager.enable = true;

  networking = {
    hostName = "kaketsugi";
    nameservers = ["1.1.1.1" "1.0.0.1"];
    #iproute2.enable = true;
    firewall = {
      allowedTCPPorts = [ 1433 ];
    };
  };



  services.borgbackup.jobs.home-ent = {
    paths = "/home/ent";
    extraArgs = "--remote-path=/home/users/entgod/borg-dir/borg.exe --remote-ratelimit 1500";
    exclude =
      [ ".cache"
        "/home/ent/iso"
        "/home/ent/downoad"
        "/home/ent/.cargo"
        "/home/ent/.rustup"
        "/home/ent/.local/share/Steam"

        # These are here for the time being so initial backup is faster
        #"/home/ent/videos"
        #"/home/ent/Camera"
        #"/home/ent/music"
        #"/home/ent/code" # have to figure out how to exclude work repos nicely
        #"/home/ent/Sync"
        #"/home/ent/violin"
        #"/home/ent/talteen"
        #"/home/ent/.config"
        #"/home/ent/.mozilla"
        #"/home/ent/.thunderbird"
        #"/home/ent/images"
        #"/home/ent/dotfiles"
        "/home/ent/.bitcoin/blocks"
      ];
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup/passphrase";
    };
    environment.BORG_RSH = "ssh -i /home/ent/.ssh/id_rsa";
    repo = "ssh://entgod@kapsi.fi:22/home/users/entgod/siilo/borg/home-ent";
    compression = "auto,zstd";
    startAt = "daily";
  };

  services.ollama = {
    enable = true;
  };

  # services.openvpn.servers.tofumanDevVpn.config = "/home/ent/download/cvpn-endpoint-0d73c35031acbf471.ovpn";

  fonts.fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
  ];

  environment = {
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    systemPackages = with pkgs; [
      kubectl
      minikube
    ];
    sessionVariables = {
      GTK_IM_MODULE="ibus";
      QT_IM_MODULE="ibus";
    };
  };


  services.mullvad-vpn.enable = true;

  services.ratbagd.enable = true; # configuration service for logitech mice

  services.openssh.enable = true;
  programs.dconf.enable = true;

  # https://github.com/Mic92/envfs
  services.envfs.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver = {
    exportConfiguration = lib.mkForce true;
    videoDrivers = ["amdgpu"];
    config = ''
      Section "InputClass"
        Identifier "My Mouse"
        Driver "libinput"
        MatchIsPointer "yes"
        Option "AccelProfile" "flat"
        Option "AccelSpeed" "-1"
      EndSection
    '';

    deviceSection = ''
      #Option "SWCursor" "on"
      #Option "HWCursor" "off"
      Option "TearFree" "true"
      Option "VariableRefresh" "true"
      Option "DRI" "3"
      Option "Monitor-DisplayPort-1" "Monitor[0]"
    '';

    monitorSection = ''
      Modeline "3840x2160_240.00" 2330.75  3840 3888 3920 4000  2160 2163 2168 2429 +hsync -vsync
      Option "PreferredMode" "3840x2160_240.00"
      Option "DPMS" "true"
    '';
  };

  services.syncthing = {
    enable = true;
    user = "ent";
    group = "users";
    openDefaultPorts = true;
    configDir = "/home/ent/.config/syncthing";
    dataDir = "/home/ent/.config/syncthing/db";
  };

  nix.settings.trusted-users = [ "root" "ent" ];

  users.groups = { plugdev = {}; };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.ent = {
    isNormalUser = true;
    shell = pkgs.fish;
    home = "/home/ent";
    extraGroups = ["wheel" "libvirtd" "video" "plugdev" "docker" "jackaudio" "dialout"];
  };

  users.extraUsers.johanna = {
    isNormalUser = true;
    home = "/home/johanna";
    extraGroups = ["libvirtd"];
  };

  security.polkit.enable = true;

  services.udev.extraRules =
    ''
    # Teensy rules for the Ergodox EZ programming
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Rule for the Ergodox EZ Original / Shine / Glow
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
    # Rule for the Planck EZ Standard / Glow
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Rule for the stlink programmer
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", \
    MODE:="0666", \
    SYMLINK+="stlinkv2_%n"
    '';

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";
}
