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
      "cyberduck"
      "discord"
      "figma"
      "ghostty"
      "github"
      "dockdoor"
      "hyperkey"
      "obsidian"
      "ollama-app"
      "shottr"
      "slack"
      "typewhisper/tap/typewhisper"
      "xykong/tap/flux-markdown"
    ];
  };
}
