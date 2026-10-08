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
mkdir -p ~/src/jarv ~/.config/opencode ~/.config/herdr ~/.ssh && chmod 700 ~/.ssh && cd ~/src/jarv
git clone https://github.com/jarv/dotfiles.git      # https until ssh keys are set up (step 5)
D=~/src/jarv/dotfiles

ln -sf  $D/dotfile.zshrc            ~/.zshrc
ln -sf  $D/dotfile.bashrc           ~/.bashrc
ln -sf  $D/dotfile.bash_profile     ~/.bash_profile
ln -sfn $D/dotfile.git              ~/.config/git
ln -sf  $D/dotfile.cvsignore        ~/.cvsignore
ln -sf  $D/dotfile.starship.toml    ~/.config/starship.toml
ln -sfn $D/dotfile.mise             ~/.config/mise
ln -sfn $D/dotfile.atuin            ~/.config/atuin
ln -sf  $D/dotfile.herdr/config.toml ~/.config/herdr/config.toml
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

Never add `openssh` (the system ssh is used everywhere). The workstation uses
the `tailscale-app` cask for the native menu-bar app; the server uses the
`tailscale` formula for `tailscale serve` and Tailscale SSH.

## 5. SSH keys and git signing (password-manager agents)

No hardware keys and no private keys on disk: ssh keys live in a
password-manager SSH agent (1Password and/or Bitwarden), and the system
`ssh` talks to it. Which agent serves which host is machine-specific, so it
lives in the untracked `~/.config/ssh/config.local`, which `dotfile.ssh.config`
includes first. Example (the work Mac serves GitHub/GitLab from Bitwarden):

```
Host github.com gitlab.com
  IdentityAgent ~/.bitwarden-ssh-agent.sock
  IdentityFile ~/.config/ssh/github_bitwarden.pub
  IdentitiesOnly yes
```

Turn the agent on in the password manager (Bitwarden: Settings > SSH agent;
1Password: Settings > Developer > "Use the SSH agent"). The `IdentityFile` is
the *public* key; it tells ssh which agent key to offer.

### Git signing with 1Password

`dotfile.git/config` is shared with Linux, so it hardcodes the Linux signer
(`gpg.ssh.program = /opt/1Password/op-ssh-sign`) and
`user.signingkey = ~/.ssh/github_personal.pub`. On macOS:

1. Make sure 1Password's SSH agent is on (above).
2. Write the public half of the signing key to the file git expects (public
   keys are not secret; the key name is whatever it is called in 1Password):

   ```sh
   SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock \
     ssh-add -L | grep ' GitHub Personal$' > ~/.ssh/github_personal.pub
   ```

3. Opt in to the macOS signer path. Git has no per-OS conditional, so this
   goes in the untracked `machine.local.gitconfig` that `dotfile.git/config`
   includes last (`os.macos.gitconfig` is tracked and holds the macOS
   `op-ssh-sign` path):

   ```sh
   printf '[include]\n    path = os.macos.gitconfig\n' > ~/.config/git/machine.local.gitconfig
   git config gpg.ssh.program      # -> /Applications/1Password.app/Contents/MacOS/op-ssh-sign
   ```

The first signed commit may fail with `1Password: failed to fill whole
buffer` if 1Password is locked or waiting on an approval prompt; approve it
and retry.

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

The `Host homer` stanza in `dotfile.ssh.config` means `ssh homer` and
`mosh homer` work as soon as both machines are on the tailnet. Add your ssh
public key (`ssh-add -L`, with the password-manager agent running) to
`homer:~/.ssh/authorized_keys`.

## 7. opencode

Config is the symlinked `dotfile.opencode.json` (permissions, MCP servers,
gitlab provider, and the `homer` local provider). Nothing to do beyond
`mise install`. Run `opencode auth login` for the gitlab provider.

## 8. Shell

`chsh -s /bin/zsh` is the default on macOS already. Log out/in once so
`bash_profile`/`zprofile` ordering, `brew shellenv` and `mise activate` are
all picked up from a clean login shell.

## 9. Free up Ctrl+Space (herdr prefix)

`dotfile.herdr/config.toml` sets `prefix = "ctrl+space"`. macOS reserves that
combo for "Select the previous input source" and swallows it before the
terminal sees it, so herdr never gets the prefix. Disable the shortcut:

**System Settings > Keyboard > Keyboard Shortcuts... > Input Sources**, then
uncheck "Select the previous input source" (Ctrl+Space).

If it still does not take effect, log out and back in.

## 10. Optional macOS defaults

```sh
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.dock autohide -bool true
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
killall Finder Dock WindowManager
```
