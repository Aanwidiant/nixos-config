{ ... }:

{
  security.sudo.enable = true;
  security.polkit.enable = true;

  environment.pathsToLink = [ "/libexec" ];

  security.pam.services.quickshell = {
    text = ''
      auth include login
      account include login
    '';
  };
}
