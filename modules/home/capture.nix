{ pkgs, ...}:

{
  home.packages = with pkgs; [
    pulseaudio
    grim
    slurp
    satty
    wl-clipboard
    ffmpeg
    cliphist
    wtype
  ];
}
