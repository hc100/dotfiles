{ pkgs, ... }:

{
  home.file.".p10k.zsh".source = ../p10k.zsh;

  home.sessionPath = [
    "$HOME/.local/share/aquaproj-aqua/bin"
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/$USER/bin"
    "/nix/var/nix/profiles/default/bin"
    "$HOME/bin"
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

      # Fall back to the launchd ssh-agent socket when the configured
      # SSH_AUTH_SOCK is missing or stale.
      if [[ -z "$SSH_AUTH_SOCK" || ! -S "$SSH_AUTH_SOCK" ]]; then
        if command -v launchctl >/dev/null 2>&1; then
          _sock=$(launchctl getenv SSH_AUTH_SOCK 2>/dev/null)
          [[ -n "$_sock" && -S "$_sock" ]] && export SSH_AUTH_SOCK="$_sock"
          unset _sock
        fi
      fi

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
      awsp = "source _awsp";
    };

    initContent = ''
      if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
      fi

      if [[ -r "$HOME/.p10k.zsh" ]]; then
        source "$HOME/.p10k.zsh"
      fi

      ulimit -n 524288

      # Copy the path of the most recent screenshot to the clipboard.
      latest_ss() {
        local dir="$HOME/Screenshots"
        local -a files
        files=("$dir"/*(.Nom))
        if (( ''${#files} == 0 )); then
          echo "latest_ss: no screenshots found in $dir" >&2
          return 1
        fi
        printf '%s' "''${files[1]}" | pbcopy
        echo "''${files[1]}"
      }

      if [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null 2>&1; then
        . "$(kiro --locate-shell-integration-path zsh)"
      fi

      # herdr が spawn する claude(復元時の `claude --resume` 含む) を Bedrock で
      # 動かすため、サブシェル内でのみ Bedrock env を読み込んで herdr を起動する。
      # env はサーバ起動時に子プロセスへ継承される。対話シェルや素の claude は汚さない。
      # 秘匿値を含む env は git 管理外の ~/.config/bedrock/env.sh(あれば)から読み込む。
      herdr() {
        ( [[ -r "$HOME/.config/bedrock/env.sh" ]] && . "$HOME/.config/bedrock/env.sh"; command herdr "$@" )
      }

      if [ -d "$HOME/.config/composer/vendor/bin" ]; then
        export PATH="$HOME/.config/composer/vendor/bin:$PATH"
      fi

      if [ -d "$HOME/.composer/vendor/bin" ]; then
        export PATH="$HOME/.composer/vendor/bin:$PATH"
      fi

      # Prefer aqua-managed CLIs, then Nix-managed tools over Homebrew while
      # keeping Homebrew available for GUI/macOS-integrated tools.
      typeset -U path
      path=(
        $HOME/.local/share/aquaproj-aqua/bin
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
