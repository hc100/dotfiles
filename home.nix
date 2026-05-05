{ config, pkgs, username, ... }:

{
  imports = [
    ./modules/zsh.nix
    ./modules/nix.nix
    ./modules/git.nix
    ./modules/ssh.nix
    ./modules/emacs.nix
    ./modules/ghostty.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";

    sessionVariables = {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

    file.".local/bin/bootstrap-ssh-config" = {
      source = ./scripts/bootstrap-ssh-config;
      executable = true;
    };

    packages = with pkgs; [
      bat
      curl
      direnv
      fd
      fzf
      gh
      git
      jq
      nodejs_24
      ripgrep
      tree
      wget
    ];
  };

  programs.home-manager.enable = true;
}
