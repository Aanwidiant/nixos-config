{ pkgs, ...}:

{
  home.packages = with pkgs; [
    grim
    slurp
    satty
    wayfreeze
    wl-clipboard
    gpu-screen-recorder
    ffmpeg
  ];
}
