{ pkgs, ...}:

{
  home.packages = with pkgs; [
    # Editors & Version Control
    neovim
    zed-editor
    jetbrains.webstorm
    # android-studio
    bruno
    github-cli
    lazygit
    lazydocker

    # Nix Tools
    nil
    nixd
    nixpkgs-fmt

    # Runtimes & Build Tools
    cmake
    gcc
    docker-compose
    nodejs_25
    pnpm
    android-tools
    gnumake
    python3
    readline
    ncurses
    imagemagick
    pkg-config
    luajit
    lua51Packages.luarocks-nix
    sshfs
    prisma-engines
    tree-sitter

    ollama
  ];
}
