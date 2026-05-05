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

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    xykong-tap = {
      url = "github:xykong/homebrew-tap";
      flake = false;
    };

    typewhisper-tap = {
      url = "github:TypeWhisper/homebrew-tap";
      flake = false;
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nix-homebrew,
      typewhisper-tap,
      xykong-tap,
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
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            {
              users.users.${username}.home = "/Users/${username}";

              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = username;
                autoMigrate = true;
                taps = {
                  "typewhisper/homebrew-tap" = typewhisper-tap;
                  "xykong/homebrew-tap" = xykong-tap;
                };
              };

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
