{ pkgs, ... }:

{
  home.file.".p10k.zsh".source = ../p10k.zsh;

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/$USER/bin"
    "/nix/var/nix/profiles/default/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    envExtra = ''
      export NVM_DIR="$HOME/.nvm"

      # Keep the default nvm Node available in non-interactive zsh without
      # sourcing nvm.sh on every shell startup.
      if [[ -r "$NVM_DIR/alias/default" ]]; then
        nvm_default_version="$(<"$NVM_DIR/alias/default")"
        nvm_default_version="''${nvm_default_version%%[[:space:]]*}"

        if [[ "$nvm_default_version" != "system" ]] \
          && [[ -d "$NVM_DIR/versions/node/$nvm_default_version/bin" ]]; then
          typeset -U path
          path=("$NVM_DIR/versions/node/$nvm_default_version/bin" $path)
        fi

        unset nvm_default_version
      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = {
      ll = "ls -la";
      g = "git";
      gs = "git status --short";
    };

    initContent = ''
      if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
      fi

      if [[ -r "$HOME/.p10k.zsh" ]]; then
        source "$HOME/.p10k.zsh"
      fi

      ulimit -n 524288

      if [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null 2>&1; then
        . "$(kiro --locate-shell-integration-path zsh)"
      fi

      if [ -d "$HOME/.config/composer/vendor/bin" ]; then
        export PATH="$HOME/.config/composer/vendor/bin:$PATH"
      fi

      if [ -d "$HOME/.composer/vendor/bin" ]; then
        export PATH="$HOME/.composer/vendor/bin:$PATH"
      fi

      # Prefer Nix-managed CLI tools over Homebrew while keeping Homebrew
      # available for GUI/macOS-integrated tools.
      typeset -U path
      path=(
        /run/current-system/sw/bin
        /etc/profiles/per-user/$USER/bin
        /nix/var/nix/profiles/default/bin
        $path
      )
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
