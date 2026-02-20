{ pkgs, ...}:

{
  home.packages = with pkgs; [
    wf-recorder
    pulseaudio
    slurp
    satty
    wl-clipboard
    ffmpeg
    cliphist
  ];
}
