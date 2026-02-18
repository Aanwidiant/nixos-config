{ pkgs, ...}:

{
  home.packages = with pkgs; [
    # Data & Text Processing
    jq
    bc
    xmlstarlet

    # File & Search Tools
    cliphist
    fd
    dust
    bat
    eza
    tldr

    # System & Hardware Control
    libnotify
    brightnessctl
    pamixer
    playerctl

    # XDG & Desktop Integration
    xdg-utils
    xdg-terminal-exec
    libxkbcommon
  ];
}
