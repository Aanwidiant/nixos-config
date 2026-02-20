{ ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire."92-low-sample-rate" = {
      "context.properties" = {
        "default.clock.rate" = 44100;
      };
    };
  };
}
