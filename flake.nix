{
  description = "Reproducible macOS and user environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # gh の --attach フラグ（gh 2.99.0 以降）を使うため、gh だけ新しい nixpkgs から取得する。
    # メインの nixpkgs は据え置き、この input は gh の上書き専用。
    # nixos-unstable チャネルはまだ gh 2.98.0 のため、gh 2.99.0 を含む master コミットに rev 固定する。
    nixpkgs-gh.url = "github:NixOS/nixpkgs/583e985cf51f566151e5bc99305070a0f819c15a";

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
      nixpkgs-gh,
      home-manager,
      nix-darwin,
      nix-homebrew,
      typewhisper-tap,
      xykong-tap,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
      };

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

              # gh のみ新しい nixpkgs（nixpkgs-gh）へ差し替える overlay。
              # home-manager.useGlobalPkgs = true のため home.nix の pkgs.gh もこれを参照する。
              nixpkgs.overlays = [
                (final: prev: {
                  gh = nixpkgs-gh.legacyPackages.${system}.gh;
                })
              ];

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
      packages.${system} = {
        awsp = pkgs.callPackage ./packages/awsp.nix { };
        dev-browser = pkgs.callPackage ./packages/dev-browser.nix { };
        emacs-lolipop = pkgs.callPackage ./packages/emacs-lolipop.nix { };
        speca-cli = pkgs.callPackage ./packages/speca-cli.nix { };
      };

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
