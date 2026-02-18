{ pkgs, ...}:

{
  home.packages = with pkgs; [
    dbgate
    mongodb-compass
  ];
}
