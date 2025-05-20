{username}: { config, pkgs, ... }:

{
  home.username = username;
  home.keyboard = null;
  home.homeDirectory = "/home/" + username;

  home.packages = [
    # devenv
    pkgs.devenv

    pkgs.anki
    pkgs.arandr
    pkgs.aws-vault
    pkgs.aria2
#    pkgs.arduino
#    pkgs.autoconf
    pkgs.audacity
    #pkgs.awscli2
    pkgs.aws-iam-authenticator
    pkgs.aider-chat


#    pkgs.automake
    pkgs.bashmount
#    pkgs.beekeeper-studio
    #pkgs.binutils-unwrapped
    pkgs.cachix
    pkgs.cantarell-fonts
    pkgs.chromium
    pkgs.cheese
    pkgs.gthumb
    pkgs.git
    pkgs.gcc
    pkgs.dbeaver-bin
    pkgs.bind
    pkgs.dmenu
    pkgs.evince
    (pkgs.emacs30.override { imagemagick = pkgs.imagemagickBig; })

    #pkgs.eagle
    pkgs.exiftool
    pkgs.feh
    pkgs.file
    pkgs.fira-code # monospace font with ligatures
    pkgs.firefox
    pkgs.foliate
    #(pkgs.freecad.override { spaceNavSupport = false; }) # spaceNavSupport causes segfault on start
    pkgs.freecad
    pkgs.peek
    #pkgs.python39Full
    pkgs.ghc
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
    pkgs.pandoc
    pkgs.poppler_utils
    pkgs.pavucontrol
    pkgs.plantuml
    pkgs.piper # control logitech mouse
    pkgs.powertop
    pkgs.postgresql_17
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
    pkgs.transmission_3-gtk
    pkgs.texlive.combined.scheme-full
    pkgs.unison-ucm
    pkgs.rxvt-unicode-emoji
    pkgs.units
    pkgs.unzip
    pkgs.mpv
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
    pkgs.yt-dlp
    pkgs.zotero
  ];


  home.sessionVariables = {
    GTK_IM_MODULE="ibus";
    QT_IM_MODULE="ibus";
    AWS_VAULT_BACKEND="file";
    AWS_SESSION_TOKEN_TTL="8h";
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

  home.file.".local/share/applications/ytdlp-get.desktop".text =
    ''
    [Desktop Entry]
    Name=Ytdlp-stream Protocol handler
    Exec=ytdlp-get %u
    Type=Application
    MimeType=x-scheme-handler/ytdlp-get;
    NoDisplay=true
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
    stateHome = "/home/" + username + "/.local/state";

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
      "x-scheme-handler/ytdlp-get" = ["ytdlp-get.desktop"];
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
  programs.direnv.enableBashIntegration = true;
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

  programs.home-manager.enable = true;
  programs.man.enable = true;

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

  # use bash as login shell but exec fish when interactive
  programs.bash = {
    initExtra = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
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
}
