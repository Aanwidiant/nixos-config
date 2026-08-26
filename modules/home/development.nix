{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Editors & Version Control
    neovim
    zed-editor
    bruno
    github-cli
    lazygit
    lazydocker

    # Nix Tools
    nil
    nixd
    nixpkgs-fmt

    # Runtimes & Build Tools
    gcc
    nodejs_26
    pnpm
    android-tools
    gnumake
    python3
    pkg-config
    sshfs
    tree-sitter
    ollama
    jre
  ];
}
