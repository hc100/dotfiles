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
      "obsidian"
      "ollama"
      "shottr"
      "slack"
      "xykong/tap/flux-markdown"
    ];
  };
}
