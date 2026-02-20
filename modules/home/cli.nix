{ pkgs, ...}:

{
  home.packages = with pkgs; [
    # Data & Text Processing
    jq
    bc
    xmlstarlet

    # File & Search Tools
    fd
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
    libcanberra-gtk3
  ];
}
