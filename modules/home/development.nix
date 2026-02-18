{ pkgs, ...}:

{
  home.packages = with pkgs; [
    # Editors & Version Control
    neovim
    zed-editor
    jetbrains.webstorm
    postman
    github-cli
    lazygit
    lazydocker

    # Nix Tools
    nil
    nixd
    nixpkgs-fmt

    # Runtimes & Build Tools
    bun
    phpPackages.composer
    cmake
    gcc
    docker-compose
    nodejs_24
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
    prisma-engines
    openssl
    nodePackages.prisma

    ollama
  ];
}
