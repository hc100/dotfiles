{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homebrew;
in

{
  environment.variables.HOMEBREW_NO_INSTALL_FROM_API = "1";

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
}
