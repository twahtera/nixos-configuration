# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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
    device = "/home/swapfile";
  }];

  powerManagement.cpuFreqGovernor = "performance";
    
  # fileSystems."/home".device = "/dev/disk/by-label/home";
  fileSystems."/home".device = "/dev/disk/by-uuid/fba97cf9-9f6e-41a3-95ee-954da238fa5d";
  # fileSystems."/vm".device = "/dev/disk/by-label/win";
  boot.loader.grub.device = "/dev/sda";


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

  virtualisation.docker.enable = true;

  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemu = {
  #     package = pkgs.qemu_kvm;
  #     runAsRoot = true;
  #     swtpm.enable = true;
  #     ovmf = {
  #       enable = true;
  #       packages = [(pkgs.OVMF.override {
  #         secureBoot = true;
  #         tpmSupport = true;
  #       }).fd];
  #     };
  #   };
  # };


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

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fi";
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = ["en_US.UTF-8/UTF-8"];
    extraLocaleSettings = {
      LC_CTYPE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
  };

  fonts.fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
  ];

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  environment = {
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    systemPackages = with pkgs; [
      polkit_gnome
      sudo
      man-pages
      rxvt-unicode-unwrapped

      xorg.xmodmap
      dmenu

      haskellPackages.xmonad

      #OVMF

      emacs

      #    amdgpu
      #libGL

      gnumake
      git
      gcc
      ncurses

      ntfs3g

      home-manager
    ];
    sessionVariables = {
      GTK_IM_MODULE="ibus";
      QT_IM_MODULE="ibus";
    };
  };



  nixpkgs.config = {
    allowUnfree = true;
  };
  
  # hardware.pulseaudio = {
  #   enable = true;
  #   package = pkgs.pulseaudio.override { jackaudioSupport = true; };
  # };

  # services.jack = {
  #   jackd.enable = true;
  #   alsa.enable = false;
  #   loopback = {
  #     enable = true;
  #   };
  # };

  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  #sound.enable = false;

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };


  # List services that you want to enable:

  # services.openvpn.servers = {
  #   mullvad = {
  #     autoStart = false;
  #     updateResolvConf = true;
  #     config = '' config /root/mullvad_config_linux_fi_hel '';
  #   };
  # };

  services.mullvad-vpn.enable = true;

  services.ratbagd.enable = true; # configuration service for logitech mice
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };

  services.fstrim.enable = true;
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

  # Enable the X11 windowing system.
  services.xserver = {
    exportConfiguration = true;
    enable = true;
    xkb.layout = "fi";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
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
#    Section "Device"
      Option "SWCursor" "on"
      Option "HWCursor" "off"
      Option "VariableRefresh" "true"
#    EndSection
    '';
  };

  # services.xserver.xkbOptions = "eurosign:e";

  documentation.info.enable = true;

  services.xserver.displayManager.lightdm.enable = true;

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
     Rule for the Planck EZ Standard / Glow
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Rule for the stlink programmer
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", \
    MODE:="0666", \
    SYMLINK+="stlinkv2_%n"
    '';

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";
}
