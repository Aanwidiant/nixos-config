{ pkgs, config, ... }:

let
  lockScript = pkgs.writeShellScriptBin "quickshell-lock" ''
    ${pkgs.util-linux}/bin/flock -n /tmp/quickshell-lock.lock -c \
      '${pkgs.quickshell}/bin/quickshell -p ${config.home.homeDirectory}/.config/quickshell/lock.qml'
  '';
in
{
  services.swayidle = {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];
    extraArgs = [ "-w" ];
    events = {
      before-sleep = "${lockScript}/bin/quickshell-lock &";
      lock = "${lockScript}/bin/quickshell-lock &";
    };
    timeouts = [
      {
        timeout = 600;
        command = "mmsg dispatch sleep_monitor";
        resumeCommand = "mmsg dispatch wakeup_monitor";
      }
      {
        timeout = 660;
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        timeout = 1200;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
