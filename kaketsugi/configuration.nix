# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./scarlett2i2-pulse.nix
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
    systemPackages = with pkgs; [ ];
    sessionVariables = {
      GTK_IM_MODULE="ibus";
      QT_IM_MODULE="ibus";
    };
  };


  services.mullvad-vpn.enable = true;

  services.ratbagd.enable = true; # configuration service for logitech mice

  services.openssh.enable = true;
  programs.dconf.enable = true;

  # Automatically creates a loader in /lib/* to avoid patching stuff
  # To disable it temporarily use
  # unset NIX_LD
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # List by default
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd

      # Required
      glib
      gtk2

      # Without these it silently fails
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXi
      xorg.libSM
      xorg.libICE
      #gnome2.GConf
      nspr
      nss
      cups
      libcap
      SDL2
      libusb1
      dbus-glib
      ffmpeg
      # Only libraries are needed from those two
      libudev0-shim

      # needed to run unity
      gtk3
      icu
      libnotify
      gsettings-desktop-schemas
      # https://github.com/NixOS/nixpkgs/issues/72282
      # https://github.com/NixOS/nixpkgs/blob/2e87260fafdd3d18aa1719246fd704b35e55b0f2/pkgs/applications/misc/joplin-desktop/default.nix#L16
      # log in /home/leo/.config/unity3d/Editor.log
      # it will segfault when opening files if you don’t do:
      # export XDG_DATA_DIRS=/nix/store/0nfsywbk0qml4faa7sk3sdfmbd85b7ra-gsettings-desktop-schemas-43.0/share/gsettings-schemas/gsettings-desktop-schemas-43.0:/nix/store/rkscn1raa3x850zq7jp9q3j5ghcf6zi2-gtk+3-3.24.35/share/gsettings-schemas/gtk+3-3.24.35/:$XDG_DATA_DIRS
      # other issue: (Unity:377230): GLib-GIO-CRITICAL **: 21:09:04.706: g_dbus_proxy_call_sync_internal: assertion 'G_IS_DBUS_PROXY (proxy)' failed

      # Verified games requirements
      xorg.libXt
      xorg.libXmu
      libogg
      libvorbis
      SDL
      SDL2_image
      glew110
      libidn
      tbb

      # Other things from runtime
      flac
      freeglut
      libjpeg
      libpng
      libpng12
      libsamplerate
      libmikmod
      libtheora
      libtiff
      pixman
      speex
      SDL_image
#      SDL_ttf  # has open cve
      SDL_mixer
      SDL2_ttf
      SDL2_mixer
      libappindicator-gtk2
      libdbusmenu-gtk2
      libindicator-gtk2
      libcaca
      libcanberra
      libgcrypt
      libvpx
      librsvg
      xorg.libXft
      libvdpau
      # ...
      # Some more libraries that I needed to run programs
      pango
      cairo
      atk
      gdk-pixbuf
      fontconfig
      freetype
      dbus
      alsa-lib
      expat
      # Needed for electron
      libdrm
      mesa
      libxkbcommon
      # Needed to run, via virtualenv + pip, matplotlib & tikzplotlib
      stdenv.cc.cc.lib # to provide libstdc++.so.6
      pkgs.gcc-unwrapped.lib # maybe only the first one needed

      # needed to run appimages
      fuse # needed for musescore 4.2.1 appimage
      e2fsprogs # needed for musescore 4.2.1 appimage

      xorg.libxcb
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
    ];
  };

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
      Option "SWCursor" "on"
      Option "HWCursor" "off"
      Option "TearFree" "true"
      Option "VariableRefresh" "true"
    '';
  };

  services.autorandr = {
    profiles = {
      default = {
        fingerprint = {
          DisplayPort-1 = "00ffffffffffff0006b3f2320101010123220104b54628783b0ad5af4e3eb5240e5054254a008140818081c0a940d1c00101010101014dd000a0f0703e8030203500bb8b2100001a000000fd0c30f0ffffea010a202020202020000000fc00504733325543444d0a20202020000000ff0053384c4d51533135313536370a02fa020344f154767561605f5e5d3f40101f2221200413121103022309070783010000e305c000e60605018b4d01e200ea741a0000030330f000a08b014d01f0000000008900565e00a0a0a0295030203500bb8b2100001ab8bc0050a0a0555008206800bb8b2100001a0000000000000000000000000000000000000000000000eb7012790300030164ca9c0104ff099f002f801f009f05b20002000400ceac0104ff0e9f006f801f006f087e0076000400e7610104ff0e9f002f801f006f08680002000400ef8e0304ff0e9f002f801f006f080c01020004005fe400047f07b3003f803f0037044f0002000400000000000000000000000000000000000000e490";
        };
        config = {
          DisplayPort-1 = {
            enable = true;
            primary = true;
            mode = "3840x2160";
            rate = "240";
          };
        };
      };
    };
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

  security.sudo.extraConfig = 
    ''
  %libvirtd ALL = NOPASSWD:  /run/current-system/sw/bin/virsh start win
                            
  '';

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
