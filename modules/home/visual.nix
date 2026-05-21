{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpegthumbnailer
    tumbler
  ];
}
