{ pkgs, ...}:

{
  home.packages = with pkgs; [
    wf-recorder
    pulseaudio
    grim
    slurp
    satty
    wl-clipboard
    ffmpeg
    cliphist
    wtype
    wl-mirror
  ];
}
