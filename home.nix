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
      EDITOR = "vi";
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

    file.".local/bin/bootstrap-ssh-config" = {
      source = ./scripts/bootstrap-ssh-config;
      executable = true;
    };

    packages = with pkgs; [
      act
      automake
      awscli2
      (pkgs.callPackage ./packages/awsp.nix { })
      bat
      phpPackages.composer
      curl
      (pkgs.callPackage ./packages/dev-browser.nix { })
      direnv
      fd
      ffmpeg
      fzf
      gcc
      gh
      git
      git-lfs
      gnupg
      go
      imagemagick
      jq
      mariadb.client
      mkcert
      nodejs_24
      oath-toolkit
      pinact
      pkgconf
      qpdf
      ripgrep
      silver-searcher
      (pkgs.callPackage ./packages/speca-cli.nix { })
      tbls
      texinfo
      terraform
      tree
      tree-sitter
      uv
      wget
      yarn
    ];
  };

  programs.home-manager.enable = true;
}
