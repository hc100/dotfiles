{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };

    taps = [
      "xykong/tap"
    ];

    casks = [
      "flux-markdown"
    ];
  };
}
