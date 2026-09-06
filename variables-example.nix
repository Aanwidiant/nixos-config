# Copy this file to variables.nix and fill in your actual values.
# variables.nix is gitignored, so it won't be committed to the repo.
{
  # System architecture (e.g. "x86_64-linux", "aarch64-linux")
  system = "x86_64-linux";

  # System username (used for home-manager.users.<username> and home directory path)
  username = "username";

  # Hostname of the machine (used as the key for nixosConfigurations.<hostname>)
  hostname = "hostname";

  # Git identity, passed to home-manager via extraSpecialArgs
  gitUser = {
    name = "git_user";
    email = "email@mail.com";
  };
}
