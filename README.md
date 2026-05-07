# dotfiles

Nix, Home Manager, and nix-darwin based macOS environment configuration.

## Scope

- CLI packages: Nix/Home Manager
- User dotfiles: Home Manager
- macOS defaults: nix-darwin
- GUI apps: Homebrew via nix-darwin allowlist
- 1Password CLI: Homebrew/app install, not Nix-managed
- Secrets and SSH private keys: never committed

## Emacs

Home Manager manages the small, hand-written Emacs configuration files under
`~/.emacs.d`, while generated package directories and caches remain writable and
untracked.

Managed:

- `~/.emacs.d/init*.el`
- `~/.emacs.d/early-init.el`
- `~/.emacs.d/elisp/go-autocomplete.el`

Home Manager also installs the external tools used by the Emacs configuration,
including Copilot Language Server, Intelephense, gopls, rust-analyzer,
typescript-language-server, vscode-langservers-extracted, eslint_d, prettier,
goimports, and nil.

The fonts referenced by the Emacs UI configuration are also managed by Home
Manager: Moralerspace HWJPDOC and Noto Color Emoji.

## Zsh

Home Manager manages zsh, oh-my-zsh, and Powerlevel10k. The Powerlevel10k
prompt configuration is stored in `p10k.zsh` and linked to `~/.p10k.zsh`.

## Ghostty

Home Manager manages the Ghostty config at:

```text
~/Library/Application Support/com.mitchellh.ghostty/config
```

The shader files referenced by the current config are copied into this
repository under `ghostty/shaders` and managed by Home Manager. Edit those files
in this repository if you want to customize them.

Not managed:

- `~/.emacs.d/elpa`
- `~/.emacs.d/straight`
- `~/.emacs.d/eln-cache`
- histories, caches, LSP state, and native local binaries

## Homebrew

nix-darwin manages only explicitly listed Homebrew packages. Existing unlisted
Homebrew packages are left untouched because `homebrew.onActivation.cleanup` is
set to `none`.

Managed casks:

- `1password`
- `cyberduck`
- `discord`
- `dockdoor`
- `figma`
- `ghostty`
- `github`
- `hyperkey`
- `obsidian`
- `ollama-app`
- `shottr`
- `slack`
- `typewhisper/tap/typewhisper`
- `xykong/tap/flux-markdown`

Custom Homebrew taps are pinned through flake inputs via `nix-homebrew`, so tap
resolution does not depend on manual `brew tap` state.

## First Setup

On a new Mac, install Xcode Command Line Tools and Nix first. Clone with HTTPS
until SSH keys and 1Password SSH Agent are restored.

```sh
xcode-select --install
sh <(curl -L https://nixos.org/nix/install)
```

Run the first switch through Nix's absolute path. `darwin-rebuild` is not
available until after the first successful switch, and `sudo nix ...` can fail
on a fresh install because `sudo` may not inherit the user shell `PATH`.

```sh
git clone https://github.com/hc100/dotfiles.git
cd dotfiles
sudo /nix/var/nix/profiles/default/bin/nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin -- switch --flake "path:$PWD#hc100-macbook"
```

Use the configuration that matches the local macOS user:

- `hc100-macbook`: personal Mac, user `k-ozaki`
- `work-macbook`: work Mac, user `ozaki-kyoichi`

For the work Mac:

```sh
sudo /nix/var/nix/profiles/default/bin/nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin -- switch --flake "path:$PWD#work-macbook"
```

If activation stops with `Unexpected files in /etc` for `/etc/bashrc` or
`/etc/zshrc`, move those files aside and retry. This is nix-darwin refusing to
overwrite pre-existing system shell files without an explicit backup.

```sh
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo /nix/var/nix/profiles/default/bin/nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin -- switch --flake "path:$PWD#hc100-macbook"
```

After signing in to 1Password, restore the private SSH config:

```sh
op signin
DOTFILES_SSH_CONFIG_REF='op://Private/dotfiles-ssh-config/notesPlain' bootstrap-ssh-config
```

## Daily Operation

After the first switch, `darwin-rebuild` is available. Edit the Nix files, then
apply:

```sh
sudo /run/current-system/sw/bin/darwin-rebuild switch --flake "path:$PWD#hc100-macbook"
```

To build without applying changes, `sudo` is not required:

```sh
darwin-rebuild build --flake "path:$PWD#hc100-macbook"
```

If `darwin-rebuild` is not in your user `PATH`, use the full path:

```sh
/run/current-system/sw/bin/darwin-rebuild build --flake "path:$PWD#hc100-macbook"
```

After the first apply, `nix flake check` works without extra flags. Before that,
use:

```sh
nix --extra-experimental-features nix-command --extra-experimental-features flakes flake check
```

Use project-local environments instead of global npm installs:

```sh
nix develop
direnv allow
```

## SSH Config

`~/.ssh/config` is not managed by Home Manager because it can contain customer
names, internal hosts, and other work-sensitive connection details.

Store the full SSH config in 1Password as a field or file attachment, then
restore it after applying this flake:

```sh
op signin
DOTFILES_SSH_CONFIG_REF='op://Private/dotfiles-ssh-config/notesPlain' bootstrap-ssh-config
```

The value of `DOTFILES_SSH_CONFIG_REF` is a 1Password secret reference. Use the
actual vault name shown by `op`. Keep the actual host entries only in
1Password. For a Secure Note, use `notesPlain` to read the note body.

If you use the 1Password SSH Agent, include this public agent setting in the
1Password-managed SSH config:

```sshconfig
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

## Layout

```text
.
├── flake.nix
├── home.nix
├── darwin-configuration.nix
├── scripts
│   └── bootstrap-ssh-config
└── modules
    ├── emacs.nix
    ├── git.nix
    ├── ssh.nix
    └── zsh.nix
```
