# 01 - Base system

## First boot (Setup Assistant)

- Create a **standard admin account** (e.g. `jarv`). Keep the name short; it is
  used in launchd plists later.
- **Turn on FileVault** when offered (or later with `sudo fdesetup enable`).
  Yes, even for a headless box - see `02-remote-access.md` for the reboot
  workflow.
- Skip iCloud/Siri/Analytics/Apple Intelligence; none are needed.
- Do not enable Screen Time / Focus; they can interfere with automation.

After reaching the desktop, open Terminal and do everything below from there.

## Machine basics

```sh
# Hostname (used by Tailscale MagicDNS as well)
sudo scutil --set ComputerName homer
sudo scutil --set HostName homer
sudo scutil --set LocalHostName homer

# Xcode command line tools (git, clang, make - needed by brew and mise)
xcode-select --install
# wait for the dialog to finish, then:
xcode-select -p   # -> /Library/Developer/CommandLineTools

# Rosetta is NOT needed for anything in this guide.

# Auto-install macOS security updates only (no major-version surprises)
sudo softwareupdate --schedule on
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
```

## Dotfiles first (github.com/jarv/dotfiles)

The dotfiles repo already carries the shell, git, mise and opencode config,
so the box gets the same environment as every other machine with a clone and
a handful of symlinks. This replaces hand-editing `~/.zshrc`, `~/.config/git/config`
and `~/.config/mise/config.toml`.

```sh
mkdir -p ~/src/jarv ~/.config/opencode ~/.config/herdr && cd ~/src/jarv
git clone https://github.com/jarv/dotfiles.git      # https: no ssh key on the box yet
D=~/src/jarv/dotfiles
cd $D/setup/macos.server                             # rest of this guide runs from here

ln -sf  $D/dotfile.zshrc            ~/.zshrc
ln -sfn $D/dotfile.git              ~/.config/git
ln -sf  $D/dotfile.cvsignore        ~/.cvsignore
ln -sf  $D/dotfile.starship.toml    ~/.config/starship.toml
ln -sfn $D/dotfile.mise             ~/.config/mise
ln -sfn $D/dotfile.atuin            ~/.config/atuin
ln -sf  $D/dotfile.herdr/config.toml ~/.config/herdr/config.toml
ln -sf  $D/dotfile.opencode.json    ~/.config/opencode/opencode.json
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ln -sf  $D/dotfile.ssh.config       ~/.ssh/config
```

Skip `dotfile.nvim` (symlink into `../MiniMax/configs`, which is not on this
machine) and `dotfile.wezterm`.

What the existing files give you for free:

- `dotfile.zshrc`: `brew shellenv`, `mise activate`, starship, atuin, direnv,
  fzf/rg defaults, per-host history in `~/.zsh_histories/homer/`. Every
  optional tool is guarded with `command -v`, so it works before brew exists.
- `dotfile.mise/config.toml`: `uv`, `opencode`, `nodejs`, `go`, `fd`, `gh`,
  `atuin`, `direnv`, `shellcheck`, `lazygit`, ... - the whole mise tool layer.
  `opencode` being there means the box can run opencode locally with no extra
  steps (see `05-opencode-client.md`).
- `dotfile.git/config`: identity, aliases, LFS, `pull.rebase`.
- `dotfile.herdr/config.toml`: terminal theme, tmux-style keybindings and pane UI.
- `dotfile.opencode.json`: permissions / MCP / gitlab provider. The `homer`
  provider gets added to this file so every machine picks it up.

One thing in the dotfiles does **not** fit a headless box: `commit.gpgsign = true`
signs with a key from 1Password, and signing is not set up here by default.
`dotfile.git/config` includes `machine.local.gitconfig` (missing file is
ignored), so override on the box only:

```sh
printf '[commit]\n    gpgsign = false\n' > ~/.config/git/machine.local.gitconfig
```

To sign commits on the box instead, follow "Git signing with 1Password" in
`../macos.workstation/README.md` (step 5) and skip this override.

## mise (preferred installer)

Bootstrap mise directly; brew is not installed yet and
mise-first is the preference:

```sh
curl https://mise.run | sh
exec zsh                 # dotfile.zshrc activates mise (~/.local/bin is on PATH)
mise install             # everything in dotfile.mise/config.toml
mise ls
```

`mise install` also pulls `gcloud`, `awscli`, `teleport-community`, etc. that
a LLM box does not need. Either accept the few hundred MB, or run
`mise install uv opencode nodejs go fd gh atuin direnv` for the subset. Do
not fork the config - one mise config across machines is the point.

## Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"       # zshrc does this on next login
brew analytics off
```

The dotfiles repo has two Brewfiles:

| File | Use |
|---|---|
| `setup/macos.workstation/Brewfile` | full dev laptop dump (ffmpeg, docker, k8s, casks...) - **not** for this box |
| `setup/macos.server/Brewfile` | tailscale, ollama, starship, coreutils, mosh, htop, mactop |

```sh
brew bundle --file ~/src/jarv/dotfiles/setup/macos.server/Brewfile
```

`setup/macos.server/Brewfile` intentionally leaves out `cask "tailscale-app"` (conflicts
with the `tailscale` formula, which supports Tailscale SSH on macOS and runs
as a root LaunchDaemon). Neither Brewfile installs `openssh`: the system ssh is used everywhere.

Why brew and not mise for these: Ollama needs a Metal/MLX-linked native build
and Tailscale needs a root LaunchDaemon; brew formulas handle
both, mise's backends do not.

## SSH key for the box (1Password ssh agent)

Like the workstation, the box keeps its ssh key in 1Password rather than on
disk (see `../macos.workstation/README.md`, step 5). The Brewfile installs the
1Password app; the agent only runs while the app is running and unlocked, so
do this once over Screen Sharing (or with the lid open) while setting up:

1. `open -a 1Password`, sign in, and in Settings > General turn on "Start at
   login". In Settings > Developer turn on "Use the SSH agent".
2. Reuse the **GitHub Personal** SSH key item in 1Password and add its public
   key to GitHub if it is not already registered.
3. Point ssh at the agent for GitHub/GitLab in the untracked
   `~/.config/ssh/config.local` (included first by `dotfile.ssh.config`):

   ```
   Host github.com
     IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
     IdentityFile ~/.ssh/github_personal.pub
     IdentitiesOnly yes
   ```

   Save the key's *public* half from 1Password to that `IdentityFile` path
   (the SSH key item has a "Public key" field).
4. Switch the dotfiles remote to ssh:

   ```sh
   ssh -T git@github.com    # should greet you by username
   git -C ~/src/jarv/dotfiles remote set-url origin git@github.com:jarv/dotfiles
   ```

If the box is rebooted, the agent is unavailable until someone logs in and
unlocks 1Password, so git-over-ssh from the box will not work until then.
Inbound ssh to the box is unaffected (it uses your workstation's key and
`authorized_keys`, see `02-remote-access.md`).

## macOS defaults worth setting on a server

```sh
# Do not reopen apps after reboot
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
# Show full path / all extensions (nice over screen sharing)
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Do not move windows aside when clicking the desktop
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
killall WindowManager 2>/dev/null || true
# Disable Spotlight indexing of the model directories (saves CPU/IO)
sudo mdutil -i off ~/.ollama 2>/dev/null || true
```

## Free up Ctrl+Space (herdr prefix)

`dotfile.herdr/config.toml` uses `prefix = "ctrl+space"`, but macOS binds
Ctrl+Space to "Select the previous input source" and swallows it before the
terminal sees it. This matters for the local keyboard and Screen Sharing
sessions; plain ssh/mosh sessions are unaffected. Disable it anyway so the
box behaves like the other machines:

**System Settings > Keyboard > Keyboard Shortcuts... > Input Sources**, then
uncheck "Select the previous input source" (Ctrl+Space). Log out and back in
if it does not take effect.

Continue with `02-remote-access.md`.
