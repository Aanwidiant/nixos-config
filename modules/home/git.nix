{ config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = config.secrets.git.name;
        email = config.secrets.git.email;
      };
    };
  };
}
