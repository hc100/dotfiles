{ pkgs, ... }:

let
  goimportsOnly = pkgs.runCommand "goimports-only" { } ''
    mkdir -p "$out/bin"
    ln -s ${pkgs.gotools}/bin/goimports "$out/bin/goimports"
  '';

  emacsFiles = [
    "early-init.el"
    "init.el"
    "init-completion.el"
    "init-core.el"
    "init-lang-go.el"
    "init-lang-php.el"
    "init-lang-rust.el"
    "init-lang-web.el"
    "init-lsp.el"
    "init-packages.el"
    "init-ui.el"
    "init-utils.el"
    "init-vcs.el"
  ];

  managedEmacsFiles = builtins.listToAttrs (
    map (file: {
      name = ".emacs.d/${file}";
      value.source = ../emacs.d/${file};
    }) emacsFiles
  );
in
{
  programs.emacs = {
    enable = true;
  };

  home.packages = with pkgs; [
    copilot-language-server
    eslint_d
    gopls
    goimportsOnly
    intelephense
    nil
    prettier
    rust-analyzer
    typescript
    typescript-language-server
    vscode-langservers-extracted
  ];

  home.file = managedEmacsFiles // {
    ".emacs.d/elisp/go-autocomplete.el".source = ../elisp/go-autocomplete.el;
  };
}
