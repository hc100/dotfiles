{ pkgs, lib ? pkgs.lib }:

let
  emacsForLolipop = import (pkgs.path + "/pkgs/applications/editors/emacs/make-emacs.nix") {
    pname = "emacs-lolipop";
    version = "31.0.50-unstable-2026-05-07";
    variant = "mainline";

    # lolipop requires Emacs 31 after 48b80a1e2b98f22d8da21f7c89ecfd9861643408,
    # which introduced Fwindow_cursor_info. This revision is 1432 commits ahead
    # of that commit on emacs-mirror/emacs master.
    src = pkgs.fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      rev = "f20e3e473d10501ca9bc9f232ac7a0fd24ca72de";
      hash = "sha256-r7QxuQCUGD0TR6VnRH9T/AKXuwzvv1O6Um3d3EdzhRA=";
    };

    patches = _: [ ];

    meta = {
      description = "GNU Emacs 31 snapshot pinned for lolipop";
      homepage = "https://github.com/emacs-mirror/emacs";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.darwin;
      mainProgram = "emacs";
    };
  };
in
pkgs.callPackage emacsForLolipop {
  inherit (pkgs.darwin) sigtool;
  srcRepo = true;
  withImageMagick = true;
  withNativeCompilation = false;
}
