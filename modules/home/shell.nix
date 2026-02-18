{ ... }:

{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    zoxide.enable = true;
    fzf.enable = true;
    starship.enable = true;
  };
}
