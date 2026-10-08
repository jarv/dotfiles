# macOS workstation setup

Fresh Mac to daily-driver using this dotfiles repo. Terminal only.
For the always-on LLM box see `../macos.server/`.

## 1. First boot

- Admin account `jarv`, FileVault on, skip iCloud extras/Siri/Analytics.
- `xcode-select --install` and wait for it to finish.

```sh
sudo scutil --set ComputerName <name>
sudo scutil --set HostName <name>
sudo scutil --set LocalHostName <name>
```

## 2. Clone dotfiles and symlink

```sh
mkdir -p ~/src/jarv ~/.config/opencode ~/.ssh && chmod 700 ~/.ssh && cd ~/src/jarv
git clone https://github.com/jarv/dotfiles.git      # https until the YubiKey key is set up
D=~/src/jarv/dotfiles

ln -sf  $D/dotfile.zshrc            ~/.zshrc
ln -sf  $D/dotfile.bashrc           ~/.bashrc
ln -sf  $D/dotfile.bash_profile     ~/.bash_profile
ln -sfn $D/dotfile.git              ~/.config/git
ln -sf  $D/dotfile.cvsignore        ~/.cvsignore
ln -sf  $D/dotfile.starship.toml    ~/.config/starship.toml
ln -sfn $D/dotfile.mise             ~/.config/mise
ln -sfn $D/dotfile.atuin            ~/.config/atuin
ln -sfn $D/dotfile.wezterm          ~/.config/wezterm
ln -sfn $D/dotfile.nvim             ~/.config/nvim      # needs ../MiniMax checked out, see below
ln -sf  $D/dotfile.opencode.json    ~/.config/opencode/opencode.json
ln -sf  $D/dotfile.ssh.config       ~/.ssh/config
```

`dotfile.nvim` is a symlink to `../MiniMax/configs/nvim-0.12`, so clone that
repo next to dotfiles first:

```sh
git clone https://github.com/jarv/MiniMax.git ~/src/jarv/MiniMax
```

## 3. mise (tool layer)

```sh
curl https://mise.run | sh
exec zsh            # dotfile.zshrc activates mise from ~/.local/bin
mise install        # everything in dotfile.mise/config.toml
mise ls
```

This brings in languages (go, node, rust, uv), editors/CLIs (neovim, tmux,
fzf, ripgrep, fd, jq, yq, ...), git/lint tools, k8s/cloud CLIs, and the agents
(opencode, codex, herdr). The same config is used on Linux and on the server.

## 4. Homebrew (daemons, GNU userland, heavy tools, casks)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew analytics off
brew bundle --file ~/src/jarv/dotfiles/setup/macos.workstation/Brewfile
```

Rules for what goes where:

| Goes in mise (`dotfile.mise/config.toml`) | Goes in `Brewfile` |
|---|---|
| single-binary CLIs, language toolchains | daemons (tailscale, docker/colima, gnupg) |
| anything also wanted on Linux | GNU userland the zshrc expects (`coreutils`, `gnu-sed`, `grep`, ...) |
| | `starship` (zshrc evals it before `mise activate`) |
| | library-heavy tools (ffmpeg, imagemagick, graphviz, qemu) |
| | casks and fonts |

Never add `openssh` or `yubikey-agent` (see next section). The workstation uses
the `tailscale-app` cask for the native menu-bar app; the server uses the
`tailscale` formula for `tailscale serve` and Tailscale SSH.

## 5. YubiKey for ssh and git signing (no yubikey-agent)

macOS ships a PKCS11 provider at `/usr/lib/ssh-keychain.dylib` that lets the
system `ssh`/`ssh-agent` use the YubiKey PIV slot directly. `dotfile.ssh.config`
already sets `PKCS11Provider` for it (guarded so it is inert on Linux).

```sh
# once per boot (or add to a login item / launchd agent):
ssh-add -s /usr/lib/ssh-keychain.dylib      # prompts for the PIV PIN
ssh-add -L                                   # shows the PIV key
ssh-add -L | grep -i piv > ~/.ssh/yubikey_nano.pub   # what dotfile.git/config points at
```

Provision the PIV slot itself with `ykman piv keys generate 9a ...` /
`ykman piv certificates generate 9a ...` if this is a new key (ykman is in
the Brewfile). Git signing is `gpg.format = ssh` with that pubkey, so commits
sign through the same agent - nothing else to configure.

Then switch the dotfiles remote to ssh:

```sh
git -C ~/src/jarv/dotfiles remote set-url origin git@github.com:jarv/dotfiles
```

## 6. Tailscale

```sh
open -a Tailscale
```

Sign in from the menu-bar app. If macOS prompts for approval, enable Tailscale
under **System Settings > Privacy & Security**.

The `Host llmbox` stanza in `dotfile.ssh.config` means `ssh llmbox` and
`mosh llmbox` work as soon as both machines are on the tailnet. Add the
YubiKey pubkey (`ssh-add -L`) to `llmbox:~/.ssh/authorized_keys`.

## 7. opencode

Config is the symlinked `dotfile.opencode.json` (permissions, MCP servers,
gitlab provider, and the `llmbox` local provider). Nothing to do beyond
`mise install`. Run `opencode auth login` for the gitlab provider.

## 8. Shell

`chsh -s /bin/zsh` is the default on macOS already. Log out/in once so
`bash_profile`/`zprofile` ordering, `brew shellenv` and `mise activate` are
all picked up from a clean login shell.

## 9. Optional macOS defaults

```sh
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.dock autohide -bool true
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
killall Finder Dock WindowManager
```
