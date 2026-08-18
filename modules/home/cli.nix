{ pkgs, ...}:

{
  home.packages = with pkgs; [
    # Data & Text Processing
    jq
    bc
    xmlstarlet

    # File & Search Tools
    fd
    tldr
    ripgrep

    # System & Hardware Control
    libnotify
    brightnessctl
    pamixer
    playerctl

    # XDG & Desktop Integration
    xdg-utils
    xdg-terminal-exec
  ];
}
