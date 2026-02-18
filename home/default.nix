{ config, lib, ... }:

{
  imports = [
    ../modules/home/apps.nix
    ../modules/home/capture.nix
    ../modules/home/cli.nix
    ../modules/home/database.nix
    ../modules/home/development.nix
    ../modules/home/env.nix
    ../modules/home/git.nix
    ../modules/home/hyprland.nix
    ../modules/home/shell.nix
    ../modules/home/styling.nix
    ../modules/home/terminal.nix
    ../modules/home/visual.nix
    ../modules/home/vscode.nix
  ];

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${config.home.homeDirectory}/nixos-config/dotfiles/scripts/link-dotfiles.sh
  '';
}
