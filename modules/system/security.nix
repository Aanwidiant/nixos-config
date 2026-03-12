{ ... }:

{
  security.sudo.enable = true;
  security.polkit.enable = true;

  environment.pathsToLink = [ "/libexec" ];
}
