{ pkgs, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "adbusers"
      "video"
      "audio"
    ];
    shell = pkgs.bash;
  };
}
