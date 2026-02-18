{ pkgs, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vulkan-loader
      ];
    };

    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
  };

  zramSwap.enable = true;
}
