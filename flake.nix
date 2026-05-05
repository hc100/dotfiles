{
  description = "Reproducible macOS and user environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      system = "aarch64-darwin";

      mkDarwinConfiguration =
        {
          hostname,
          username,
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;

          specialArgs = {
            inherit username;
          };

          modules = [
            ./darwin-configuration.nix
            home-manager.darwinModules.home-manager
            {
              users.users.${username}.home = "/Users/${username}";

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "before-home-manager";
              home-manager.extraSpecialArgs = {
                inherit username;
              };
              home-manager.users.${username} = import ./home.nix;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        hc100-macbook = mkDarwinConfiguration {
          hostname = "hc100-macbook";
          username = "k-ozaki";
        };

        work-macbook = mkDarwinConfiguration {
          hostname = "work-macbook";
          username = "ozaki-kyoichi";
        };
      };
    };
}
