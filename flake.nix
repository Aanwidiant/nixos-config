{
  description = "NixOS Flake Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:

    let
      system = "x86_64-linux";
      username = "aanwidiant";
      hostname = "nixos";
      gitUser = {
        name = "aanwidiant";
        email = "aanwidianto01@gmail.com";
      };
    in
    {
      nixosConfigurations.${hostname} =
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs username hostname;
          };

          modules = [
            ./hosts/laptop/configuration.nix

            home-manager.nixosModules.home-manager

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = {
                inherit inputs username hostname gitUser;
              };

              home-manager.users.${username} = {
                imports = [
                  ./home/default.nix
                ];

                home.username = username;
                home.homeDirectory = "/home/${username}";
              };
            }

            ({ ... }: {
              nix.gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 7d";
              };
            })
          ];
        };
    };
}
