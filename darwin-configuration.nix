{ lib, pkgs, username, ... }:

{
  imports = [
    ./modules/homebrew.nix
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";

    config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "copilot-language-server"
        "intelephense"
        "terraform"
      ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  programs.zsh.enable = true;

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  system = {
    primaryUser = username;
    stateVersion = 6;

    defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        "com.apple.trackpad.enableSecondaryClick" = false;
      };

      dock = {
        autohide = true;
        mru-spaces = false;
        show-recents = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = false;
        TrackpadCornerSecondaryClick = 0;
        TrackpadThreeFingerDrag = false;
      };

      screencapture.location = "~/Screenshots";
    };
  };
}
