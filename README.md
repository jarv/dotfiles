## Dotfiles

Simple and easy, my important dotfiles in Git.
No install, just create a few symlinks as needed.

Machine setup guides live in `setup/`:

| Dir | For |
|---|---|
| `setup/macos.workstation/` | dev laptop: symlinks, mise, Brewfile, YubiKey via PKCS11, Tailscale |
| `setup/macos.server/` | always-on M4 Max "llmbox": Tailscale, SSH, Ollama/llama-server, models, opencode |
| `setup/linux/` | Omarchy install notes |

Tool layer is `dotfile.mise/config.toml` (shared by all machines); brew is
only for daemons, GNU userland, heavy tools and casks.
