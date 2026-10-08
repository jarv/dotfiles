# 05 - opencode on your client machines

opencode talks to any OpenAI-compatible endpoint via `@ai-sdk/openai-compatible`.
The **model key must equal the id returned by `GET /v1/models`** on the server
(`ollama list` names, or `--alias` on llama-server).

Your opencode config is `~/src/jarv/dotfiles/dotfile.opencode.json`,
symlinked to `~/.config/opencode/opencode.json` on every machine. Add the
provider there once, commit, and pull on the other machines. It already has a
`provider` block (gitlab); the `homer` key goes alongside it.

## Ollama over Tailscale (TLS via `tailscale serve`)

Add to the `provider` object in `dotfile.opencode.json`:

```json
{
  "provider": {
    "gitlab": { "...": "unchanged" },
    "homer": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "homer (Ollama)",
      "options": {
        "baseURL": "https://homer.TAILNET.ts.net/v1"
      },
      "models": {
        "qwen3-coder:30b": {
          "name": "Qwen3 Coder 30B-A3B",
          "limit": { "context": 131072, "output": 32768 }
        },
        "qwen3.5:35b-a3b-coding-nvfp4": {
          "name": "Qwen3.5 35B-A3B coding (MLX)",
          "limit": { "context": 131072, "output": 32768 }
        },
        "gpt-oss:20b": {
          "name": "gpt-oss 20B",
          "limit": { "context": 131072, "output": 32768 }
        }
      }
    }
  }
}
```

Keep `"model": "gitlab/duo-chat"` as the default if you want; switch per
session with `/models` or run `opencode -m homer/qwen3-coder:30b`. Setting
`"small_model": "homer/gpt-oss:20b"` is a cheap win either way - titles and
summaries then never leave the tailnet.

Replace `TAILNET` with your tailnet name (`tailscale status` shows it, or
`tailscale cert` output). If you used `--http=80` instead of TLS, use
`http://homer:80/v1`.

## llama-server

Same shape, different port and ids:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "homer-llama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "homer (llama-server)",
      "options": { "baseURL": "https://homer.TAILNET.ts.net:8443/v1" },
      "models": {
        "qwen3-coder:30b": {
          "name": "Qwen3-Coder 30B-A3B (llama.cpp)",
          "limit": { "context": 131072, "output": 65536 }
        }
      }
    }
  }
}
```

## Shortcut: let Ollama write the config

On a machine that has the `ollama` CLI and can reach the box:

```sh
OLLAMA_HOST=https://homer.TAILNET.ts.net ollama launch opencode --config
```

This writes an inline provider config without clobbering your existing
`opencode.json`; review and merge.

## Verify

```sh
opencode models | grep homer
opencode run -m homer/qwen3-coder:30b "list the files in this directory using a tool"
```

If tool calls do not fire: confirm the server's context is >=64k
(`OLLAMA_CONTEXT_LENGTH` / `-c`), confirm the id in `models` matches
`curl .../v1/models` exactly, and try a larger model - sub-14B models are the
usual culprit.

## Running opencode on the box itself

`opencode` is already installed by `mise install` (it is in
`dotfile.mise/config.toml`) and the same symlinked config applies. The
tailnet URL resolves from the box too, so nothing extra is needed:

```sh
ssh homer
cd ~/src/something && opencode -m homer/qwen3-coder:30b
```
