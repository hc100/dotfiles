{ config, lib, pkgs, ... }:

let
  cfg = config.homebrew;
in

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };

    casks = [
      "1password"
      "1password-cli"
      "cyberduck"
      "discord"
      "figma"
      "ghostty"
      "github"
      "dockdoor"
      "hyperkey"
      "netnewswire"
      "obsidian"
      "ollama-app"
      "moom"
      "rar"
      "session-manager-plugin"
      "shottr"
      "slack"
      "typewhisper/tap/typewhisper"
      "xykong/tap/flux-markdown"
    ];
  };

  # Avoid Homebrew's cask JSON API during nix-darwin activation. Homebrew 5.1.7
  # can fail on empty API macOS dependency entries such as `depends_on macos: {}`.
  system.activationScripts.homebrew.text = lib.mkIf cfg.enable (lib.mkForce ''
    # Homebrew Bundle
    echo >&2 "Homebrew bundle..."
    if [ -f "${cfg.prefix}/bin/brew" ]; then
      PATH="${cfg.prefix}/bin:${lib.makeBinPath [ pkgs.mas ]}:$PATH" \
      sudo \
        --preserve-env=PATH \
        --user=${lib.escapeShellArg cfg.user} \
        --set-home \
        env \
        HOMEBREW_NO_INSTALL_FROM_API=1 \
        ${cfg.onActivation.brewBundleCmd}
    else
      echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
    fi
  '');
}
