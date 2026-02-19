{ pkgs, ...}:

{
  home.packages = with pkgs; [
    satty
    wl-clipboard
    gpu-screen-recorder
    ffmpeg
    cliphist
  ];
}
