{ gitUser, ... }:

{
  programs.git = {
    enable = true;
    settings.user = gitUser;
  };
}
