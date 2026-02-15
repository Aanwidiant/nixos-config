{ config, lib, pkgs, ... }:

{
  home.username = "aanwidiant";
  home.homeDirectory = "/home/aanwidiant";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Shell & Tools Integration
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.starship.enable = true;

  # Konfigurasi Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "aanwidiant";
        email = "aanwidianto01@gmail.com";
      };
    };
  };

  # VS Code
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  # Packages (User Level)
  home.packages = with pkgs; [

    # Daily Apps / Productivity
    brave
    firefox
    libreoffice
    mousepad
    evince
    nautilus
    localsend
    imv
    mpv
    gnome-calculator
    gnome-disk-utility
    gnome-calendar
    baobab
    powertop

    # Development Editors & Tools
    neovim
    zed-editor
    jetbrains.webstorm
    postman
    github-cli
    lazygit
    lazydocker
    nil
    nixpkgs-fmt

    # Programming Runtimes & Build Tools
    bun
    phpPackages.composer
    cmake
    clang
    docker-compose
    mise
    android-tools

    # Database Tools
    dbgate
    mongodb-compass

    # Hyprland Ecosystem
    hypridle
    hyprlock
    hyprpolkitagent
    waybar
    mako
    wofi
    swayosd
    nwg-displays
    hyprpicker
    hyprsunset
    swaybg

    # Capture / Screenshot / Screenrecord
    grim
    slurp
    satty
    wayfreeze
    wl-clipboard
    gpu-screen-recorder
    ffmpeg
    v4l-utils

    # Terminal & TUI Apps
    kitty
    impala
    bluetui
    wiremix
    fastfetch
    btop

    # CLI Utilities
    jq
    bc
    xmlstarlet
    cliphist
    fd
    dust
    bat
    eza
    tldr
    libnotify
    brightnessctl
    pamixer
    playerctl

    # XDG / Desktop Utilities
    xdg-utils
    xdg-terminal-exec
    libxkbcommon

    # Visual
    terminaltexteffects
    wofi-emoji

    # Local AI
    ollama
  ];

  # Environment & Session
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "16";
    NIXOS_OZONE_WL = "1";
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

home.activation.linkDotfiles =
  lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${config.home.homeDirectory}/nixos-config/dotfiles/scripts/link-dotfiles.sh
  '';

  # Styling (Cursor & GTK)
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Yaru-blue";
      package = pkgs.yaru-theme;
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
    };
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };
}
