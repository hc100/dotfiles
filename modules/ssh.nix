{ ... }:

{
  # Do not manage ~/.ssh/config with Home Manager.
  #
  # That file contains customer and work connection details, so it is restored
  # from 1Password with `bootstrap-ssh-config` instead of being committed here.
  programs.ssh.enable = false;
}
