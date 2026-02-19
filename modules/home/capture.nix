{ pkgs, ...}:

{
  home.packages = with pkgs; [
    wf-recorder
    slurp
    satty
    wl-clipboard
    # gpu-screen-recorder
    ffmpeg
    cliphist
  ];
}
