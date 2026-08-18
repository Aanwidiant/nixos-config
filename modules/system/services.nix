{ ... }:

{
  services = {
    dbus.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    printing.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    udisks2.enable = true;
  };

  services.ollama = {
    enable = true;
    environmentVariables = {
      OLLAMA_ORIGINS = "*";
    };
  };

  virtualisation.docker.enable = true;
}
