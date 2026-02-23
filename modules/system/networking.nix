{ ... }:

{
  networking = {
      hostName = "nixos";
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
        settings = {
          connection = {
            "wifi.powersave" = 2;
          };
        };
      };

    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 3000; to = 3005; }
        { from = 5173; to = 5175; }
        { from = 5000; to = 5005; }
        { from = 6000; to = 6005; }
        { from = 8000; to = 9000; }
      ];
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  networking.wireless.iwd.settings = {
      Network = {
        EnableIPv6 = true;
      };
      General = {
        AddressRandomization = "network";
      };
    };

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";
}
