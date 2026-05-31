{ pkgs, ...}:

{
  home.packages = with pkgs; [
    dbgate
  ];
}
