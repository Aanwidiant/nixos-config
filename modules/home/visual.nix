{ pkgs, ... }:

{
  home.packages = with pkgs; [
    terminaltexteffects
    ffmpegthumbnailer
    tumbler
  ];
}
