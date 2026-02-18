{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    corefonts # Microsoft fonts
    nerd-fonts.jetbrains-mono
  ];
}
