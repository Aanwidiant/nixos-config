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
    ollama.enable = true;
  };

  virtualisation.docker.enable = true;

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "5s";
    DefaultTimeoutStartSec = "5s";
  };
}
