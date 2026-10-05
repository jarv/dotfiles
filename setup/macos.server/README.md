# M4 Max 64GB "Local LLM Box" Setup (macOS Tahoe)

Goal: a MacBook Pro that sits lid-closed, always on, serving an OpenAI-compatible
LLM API to `opencode` running on other machines, reachable only over Tailscale
and via SSH. Everything is done from the terminal.

All paths below are relative to `~/src/jarv/dotfiles/setup/macos.server/`
(the `files/` and `Brewfile` referenced in the steps live here). Clone the
dotfiles repo first - that is step 1 of `01-base.md`.

Guide files:

| File | Contents |
|---|---|
| `README.md` | This overview + order of operations |
| `01-base.md` | First boot, FileVault, mise, brew, dotfiles/shell |
| `02-remote-access.md` | Tailscale, SSH hardening, firewall |
| `03-llm-server.md` | Ollama (default) and llama-server (advanced), launchd, GPU memory |
| `04-models.md` | Which models fit in 64GB and why |
| `05-opencode-client.md` | `opencode.json` on your client machines |
| `06-always-on.md` | Power settings for lid-closed 24/7 operation (last step) |
| `Brewfile` | Server Brewfile (tailscale, ollama, llama.cpp, ...) |
| `files/` | Ready-to-copy plists, sshd config, pf anchor |

## Order of operations

1. `01-base.md`  - account, FileVault, Xcode CLT, mise, brew, shell
2. `02-remote-access.md` - Tailscale + SSH; from here on you can finish remotely
3. `03-llm-server.md` - install and daemonize the inference server
4. `04-models.md` - pull models
5. `05-opencode-client.md` - point opencode at the box
6. `06-always-on.md` - pmset so it never sleeps with the lid closed

Until step 6 the machine behaves like a normal MacBook: closing the lid puts
it to sleep, and services/Tailscale come back when it wakes. Do all testing
with the lid open (or an external display attached) until you are happy, then
flip it to always-on as the final step.

## Design decisions (short version)

- **Dotfiles drive the user environment.** `~/src/jarv/dotfiles` is cloned
  first and symlinked (`dotfile.zshrc`, `dotfile.git`, `dotfile.mise`,
  `dotfile.opencode.json`). mise installs the tool layer (incl. opencode) from
  the shared config. The dotfiles repo has `setup/macos.workstation/Brewfile` (not for
  this box) and `setup/macos.server/Brewfile` (tailscale, ollama, llama.cpp, ...). Git
  signing (YubiKey) is disabled on the box via a local include; YubiKey ssh on
  the workstation uses macOS's built-in PKCS11 provider
  (`/usr/lib/ssh-keychain.dylib`), no yubikey-agent.

- **Inference server: Ollama by default, llama-server as the power option.**
  As of 2026 Ollama runs MLX-native on Apple Silicon (0.19+), has an
  OpenAI-compatible `/v1` API with tool calling, and `ollama launch opencode`
  can auto-configure a client. `llama-server` gives more control (context, KV
  cache, sampling, multi-model router) and is what most r/LocalLLaMA / HN power
  users run. mlx-lm's server is fastest raw but has weak tool-call support, so
  it is not recommended as an agent backend. LM Studio works but is GUI-first.
- **Network: nothing listens on LAN/Internet.** Services bind to `127.0.0.1`
  and are published over the tailnet with `tailscale serve` (TLS, tailnet-only).
  SSH is key-only; optionally also Tailscale SSH.
- **Services run as LaunchDaemons with `UserName` set to your user**, so they
  start at boot without anyone logging in, but models live in your home dir.
- **FileVault stays on.** Remote reboots use `sudo fdesetup authrestart` so the
  disk is unlocked without a keyboard at the pre-boot screen.
- **MoE models (30B-A3B, 80B-A3B) are the sweet spot on a 64GB Mac** - fast
  decode, good tool calling. Dense 27-32B models fit but decode much slower.

## Quick reference

```sh
# health
tailscale status
sudo launchctl print system/com.local.ollama | head
curl -s http://127.0.0.1:11434/v1/models | jq .

# remote reboot keeping FileVault
sudo fdesetup authrestart

# logs
tail -f /var/log/ollama.log
```
