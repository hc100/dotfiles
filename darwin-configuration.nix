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

    # 電源管理設定（VPN維持と画面ロックを両立させる）
    activationScripts.postActivation.text = lib.mkAfter ''
      echo "setting pmset power management..."
      # AC電源時はシステムスリープを無効化しVPN接続を維持する
      /usr/bin/pmset -c sleep 0
      # AC電源時は蓋を閉じてもスリープしない（clamshell運用）
      /usr/bin/pmset -c disablesleep 1
      # 全電源で3分後に画面オフ（離席時のセキュリティ確保、システムは眠らせない）
      /usr/bin/pmset -a displaysleep 3
    '';

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
