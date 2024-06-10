{ config, pkgs, ... }:

{
  home.username = "twah";
  home.homeDirectory = "/home/twah";

  home.packages = [
    # devenv
    (import (fetchTarball https://install.devenv.sh/latest)).default

    pkgs.anki
    pkgs.arandr
    pkgs.aria2
#    pkgs.arduino
#    pkgs.autoconf
    pkgs.audacity
    #pkgs.awscli2
    pkgs.aws-iam-authenticator

#    pkgs.automake
    pkgs.bashmount
#    pkgs.beekeeper-studio
    #pkgs.binutils-unwrapped
    pkgs.cachix
    pkgs.cantarell-fonts
    pkgs.chromium
    pkgs.gnome.cheese
    pkgs.gthumb
    pkgs.gcc
    pkgs.dbeaver-bin
    pkgs.bind
    pkgs.dmenu
    pkgs.evince
    (pkgs.emacs29.override { imagemagick = pkgs.imagemagickBig; })

    #pkgs.eagle
    pkgs.exiftool
    pkgs.feh
    pkgs.file
    pkgs.fira-code # monospace font with ligatures
    pkgs.firefox
    #(pkgs.freecad.override { spaceNavSupport = false; }) # spaceNavSupport causes segfault on start
    pkgs.freecad
    pkgs.peek
    #pkgs.python39Full
    pkgs.ghc
    pkgs.gh
    pkgs.gimp
    #pkgs.glxinfo
    pkgs.gnumake
    pkgs.gparted
    pkgs.gphoto2
    pkgs.graphviz
    pkgs.ispell
    pkgs.imagemagick
    #pkgs.inkscape
    pkgs.jdk
    pkgs.jq
    #pkgs.kicad
    pkgs.killall
    pkgs.kitty
    pkgs.kitty-img
    pkgs.kitty-themes
    pkgs.keepassxc
    pkgs.libnotify
    pkgs.libreoffice-still
    pkgs.lorri
    pkgs.lm_sensors
    pkgs.spotifywm
    #pkgs.super-slicer
    pkgs.microsoft-edge
    #pkgs.musescore
    pkgs.mcelog
    pkgs.mpv
    pkgs.ncmpcpp
    pkgs.ncspot
    pkgs.mullvad-vpn
    pkgs.mosh
    pkgs.nix-index
    pkgs.nmap
    pkgs.ntfsprogs
    pkgs.nodejs
    pkgs.openscad
    pkgs.openvpn
    pkgs.okular
    pkgs.pandoc
    pkgs.poppler_utils
    pkgs.pavucontrol
    pkgs.plantuml
    pkgs.piper # control logitech mouse
    pkgs.powertop
    pkgs.postgresql_12
    pkgs.pgcli
    pkgs.pydf
    pkgs.qjackctl
    pkgs.ripgrep
    pkgs.rust-analyzer-unwrapped
    pkgs.obs-studio
    pkgs.silver-searcher
    pkgs.prusa-slicer
    #pkgs.solvespace
    pkgs.sqlcmd
    pkgs.slock
    pkgs.slack
    pkgs.signal-desktop
    #pkgs.stack
    pkgs.steam #often fails to build
    #pkgs.syncthing-gtk
    pkgs.sqlite
    pkgs.tree
    pkgs.transmission-gtk
    pkgs.texlive.combined.scheme-full
    #pkgs.tasksh
    pkgs.unison-ucm
    pkgs.units
    pkgs.unzip
    pkgs.youtube-dl
    #pkgs.mpv
    pkgs.v4l-utils
    pkgs.vlc
    pkgs.wally-cli # flasher for ergodox
    pkgs.wrk2
    pkgs.whois
    pkgs.wirelesstools
    pkgs.xfce.thunar
    pkgs.xorg.xbacklight
    pkgs.xorg.xev
    pkgs.xorg.xkill
    pkgs.xorg.xmodmap
    pkgs.xsettingsd
    pkgs.zotero
  ];


  home.sessionVariables = {
    GTK_IM_MODULE="ibus";
    QT_IM_MODULE="ibus";
  };

  home.file.".local/share/applications/emacsclient.desktop".text =
    ''
    [Desktop Entry]
    Name=Emacs Client
    Exec=emacsclient %u
    Icon=emacs-icon
    Type=Application
    Terminal=false
    MimeType=x-scheme-handler/org-protocol;
    '';

  home.file.".psqlrc".text =
    ''
    \set QUIET 1
    \set PROMPT1 '%n@%/%R%#%x '
    \x auto
    \set ON_ERROR_STOP on
    \set ON_ERROR_ROLLBACK interactive

    \pset null '¤'
    \pset linestyle 'unicode'

    \pset unicode_border_linestyle single
    \pset unicode_column_linestyle single
    \pset unicode_header_linestyle double

    set intervalstyle to 'postgres_verbose';

    \setenv LESS '-iMFXSx4R'
    \setenv EDITOR 'emacsclient'

    \unset QUIET
    '';

  xdg = {
    mime.enable = true;
    mimeApps.enable = true;

    mimeApps.associations.added = {
      "x-scheme-handler/http" = ["firefox.desktop"];
      "application/x-extension-htm" = ["firefox.desktop"];
      "application/x-extension-html" = ["firefox.desktop"];
      "application/x-extension-shtml" = ["firefox.desktop"];
      "application/x-extension-xht" = ["firefox.desktop"];
      "application/x-extension-xhtml" = ["firefox.desktop"];
      "application/xhtml+xml" = ["emacsclient.desktop"];
      "text/xml" = ["emacsclient.desktop"];
      "text/html" = ["firefox.desktop"];
      "x-scheme-handler/org-protocol" = ["emacsclient.desktop"];
      "image/jpeg" = ["firefox.desktop"];
    };

    mimeApps.defaultApplications = {
      "application/pdf" = [ "okularApplication_pdf.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/ftp" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = ["firefox.desktop"];
      "x-scheme-handler/unknown" = ["firefox.desktop"];
      "text/html" = [ "firefox.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
      "x-scheme-handler/msteams" = ["msteams"];
      "text/xml" = ["emacsclient.desktop"];
    };
  };

  programs.htop = {
    enable = true;
    settings = {
      highlight_base_name = true;
      hide_threads = true;
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.fzf.enable = true;
  programs.z-lua = {
    enable = true;
    enableFishIntegration = true;
    enableAliases = true;
    options = ["enhanced" "fzf"];
  };
  programs.keychain = {
    enable = true;
    enableFishIntegration = false; # this is broken
  };
  services.screen-locker = {
    enable = true;
    inactiveInterval = 1;
    lockCmd = "${pkgs.slock}/bin/slock";
  };
  programs.home-manager.enable = true;
  programs.man.enable = true;
  services.flameshot.enable = true;

  programs.autorandr = {
    enable = true;

    profiles = {
      "work" = {
        fingerprint = {
          DP-0 = "00ffffffffffff0010acf4a04c4e3530171c0104b55825783eee95a3544c99260f5054a54b00714f81008180a940d1c00101010101014c9a00a0f0402e6030203a00706f3100001a000000ff00354b43303338363530354e4c0a000000fc0044454c4c20553338313844570a000000fd001855197328000a20202020202001f002031af14d9005040302071601141f12135a2309070783010000023a801871382d40582c4500706f3100001e565e00a0a0a0295030203500706f3100001acd4600a0a0381f4030203a00706f3100001a2d5080a070402e6030203a00706f3100001a134c00a0f040176030203a00706f3100001a000000000000000000000053";
          DP-2 = "00ffffffffffff0006afeb3200000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c1100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe00423135365a414e30332e32200a000d";
        };
        config = {
          DP-2.enable = false;
          DP-0 = {
            enable = true;
            primary = true;
            mode = "3840x1600";
          };
        };
      };
      "work2" = {
        fingerprint = {
          DP-1 = "00ffffffffffff0010acf4a04c4e3530171c0104b55825783eee95a3544c99260f5054a54b00714f81008180a940d1c00101010101014c9a00a0f0402e6030203a00706f3100001a000000ff00354b43303338363530354e4c0a000000fc0044454c4c20553338313844570a000000fd001855197328000a20202020202001f002031af14d9005040302071601141f12135a2309070783010000023a801871382d40582c4500706f3100001e565e00a0a0a0295030203500706f3100001acd4600a0a0381f4030203a00706f3100001a2d5080a070402e6030203a00706f3100001a134c00a0f040176030203a00706f3100001a000000000000000000000053";
          DP-2 = "00ffffffffffff0006afeb3200000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c1100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe00423135365a414e30332e32200a000d";
        };
        config = {
          DP-2.enable = false;
          DP-1 = {
            enable = true;
            primary = true;
            mode = "3840x1600";
          };
        };
      };
      "mobile" = {
        fingerprint = {
          DP-2 = "00ffffffffffff0006afeb3200000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c1100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe00423135365a414e30332e32200a000d";
        };
        config = {
          DP-2 = {
            enable = true;
            primary = true;
            mode = "3840x2160";
          };
        };
      };
    };

  };

  programs.fish = {
    enable = true;

    interactiveShellInit =
    ''
    set -gx PATH ~/bin $PATH

    if status is-login
        keychain --clear --quiet
    end

    if test -f ~/.keychain/(hostname)-gpg-fish
        source ~/.keychain/(hostname)-gpg-fish
    end

    if test -f ~/.keychain/(hostname)-fish
       source ~/.keychain/(hostname)-fish
    end
    '';
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
