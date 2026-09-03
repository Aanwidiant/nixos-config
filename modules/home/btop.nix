{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "current";
      vim_keys = true;
      shown_boxes = "cpu mem net";
      shown_gpus = "nvidia amd intel";
    };
    package = pkgs.symlinkJoin {
      name = "btop";
      paths = [ pkgs.btop ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/btop --add-flags "--preset 2"
      '';
    };
  };
}
