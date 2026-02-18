{ config, lib, ...}:

{
  imports = [
    ../modules/home/shell.nix
    ../modules/home/git.nix
    ../modules/home/vscode.nix
    ../modules/home/desktop.nix
    ../modules/home/styling.nix
    ../modules/home/productivity.nix
    ../modules/home/development.nix
    ../modules/home/database.nix
    ../modules/home/hyprland.nix
    ../modules/home/capture.nix
    ../modules/home/terminal.nix
    ../modules/home/cli.nix
    ../modules/home/visual.nix
    ../secrets/variables.nix
  ];

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${config.home.homeDirectory}/nixos-config/dotfiles/scripts/link-dotfiles.sh
  '';
}
