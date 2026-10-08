# 05 - opencode on your client machines

opencode talks to any OpenAI-compatible endpoint via `@ai-sdk/openai-compatible`.
The **model key must equal the id returned by `GET /v1/models`** on the server
(`ollama list` names).

Your opencode config is `~/src/jarv/dotfiles/dotfile.opencode.json`,
symlinked to `~/.config/opencode/opencode.json` on every machine. Add the
provider there once, commit, and pull on the other machines. It already has a
`provider` block; the `homer` key goes alongside the existing providers.

## Ollama directly over Tailscale

Add to the `provider` object in `dotfile.opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "gitlab": { "...": "unchanged" },
    "homer": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "homer (Ollama)",
      "options": {
        "baseURL": "http://homer:11434/v1"
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

Bind Ollama to Homer's Tailscale IP as described in `03-llm-server.md`.
Clients connect directly over HTTP; Tailscale encrypts the traffic between
devices. The short name `homer` uses
Tailscale MagicDNS; enable Tailscale DNS on clients. The full name
`homer.tail1a3497.ts.net` also works on port 11434.

The checked-in config uses provider id `homer` and the actual tailnet URL.
Quit and restart opencode after changing the config, then select it with:

```sh
opencode -m homer/qwen3-coder:30b
```

From the client, verify connectivity, then restart OpenCode:

```sh
curl -sS --fail-with-body --max-time 10 http://homer:11434/api/version
opencode -m homer/qwen3-coder:30b
```

## Shortcut: let Ollama write the config

On a machine that has the `ollama` CLI and can reach the box:

```sh
OLLAMA_HOST=http://homer:11434 ollama launch opencode --config
```

This writes an inline provider config without clobbering your existing
`opencode.json`; review and merge.

## Verify

```sh
opencode models homer
opencode run -m homer/qwen3-coder:30b "list the files in this directory using a tool"
```

If tool calls do not fire: confirm the server's context is >=64k
(`OLLAMA_CONTEXT_LENGTH`), confirm the id in `models` matches
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
