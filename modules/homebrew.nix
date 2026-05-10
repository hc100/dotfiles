{ ... }:

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
}
