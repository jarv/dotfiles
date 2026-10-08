# 03 - Inference server

Two options are documented. Pick **A** unless you know you want B.

| | A: Ollama | B: llama-server (llama.cpp) |
|---|---|---|
| Backend on Apple Silicon | MLX-native (0.19+, preview) with GGML fallback | GGML -> Metal |
| Model mgmt | `ollama pull`, registry, auto load/unload | GGUF files, `-hf repo:quant`, router mode for many models |
| Tool calling | Yes | Yes (`--jinja`, best-in-class parsers) |
| Control | env vars | every flag |
| opencode setup | `ollama launch opencode` or manual | manual |

You can also run both at the same time on different ports.

## Prerequisite: raise the GPU wired-memory limit

macOS caps how much unified memory the GPU may wire, well below 64GB. Models
in the ~50GB range (Qwen3-Coder-Next 4-bit) will fail to load without this.
Not persistent across reboots, so install it as a LaunchDaemon:

```sh
sudo sysctl iogpu.wired_limit_mb=57344      # 56GB now; leave ~8GB for the OS
sudo cp files/com.local.iogpu-wired-limit.plist /Library/LaunchDaemons/
sudo launchctl bootstrap system /Library/LaunchDaemons/com.local.iogpu-wired-limit.plist
sysctl iogpu.wired_limit_mb
```

Do not go higher than ~58000 on 64GB or the OS starts paging and the whole
machine gets slow.

## Option A: Ollama

Installed via `setup/macos.server/Brewfile` (`brew install ollama`). Do **not** also install
the Ollama.app; both use port 11434.

Do not use `brew services` here: run with `sudo` it runs as root and puts
models in `/var/root/.ollama`; without `sudo` it is a LaunchAgent and dies
when nobody is logged in. Use the custom LaunchDaemon instead:

```sh
sudo cp files/com.local.ollama.plist /Library/LaunchDaemons/
sudo sed -i '' "s/USERNAME/$USER/g" /Library/LaunchDaemons/com.local.ollama.plist
sudo chown root:wheel /Library/LaunchDaemons/com.local.ollama.plist
sudo touch /var/log/ollama.log && sudo chown $USER /var/log/ollama.log
sudo launchctl bootstrap system /Library/LaunchDaemons/com.local.ollama.plist
sleep 2; curl -s http://127.0.0.1:11434/api/version
```

The plist sets:

| Env | Value | Why |
|---|---|---|
| `OLLAMA_HOST` | `127.0.0.1:11434` | never on LAN; exposed via `tailscale serve` |
| `OLLAMA_CONTEXT_LENGTH` | `131072` | opencode wants >=64k; Ollama's default on >=48GB is 256k which wastes RAM |
| `OLLAMA_KEEP_ALIVE` | `-1` | keep the model loaded, no 5-min unload -> no cold starts |
| `OLLAMA_NUM_PARALLEL` | `1` | KV memory scales with parallel x ctx |
| `OLLAMA_FLASH_ATTENTION` | `1` | required for KV quantisation, faster |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | halves KV memory with negligible loss (do not use q4_0 - hurts tool calling) |
| `OLLAMA_MAX_LOADED_MODELS` | `2` | e.g. one coder + one small model |
| `OLLAMA_NO_CLOUD` | `1` | disable cloud model routing |
| `OLLAMA_MODELS` | `/Users/USERNAME/.ollama/models` | explicit |

Manage:

```sh
sudo launchctl kickstart -k system/com.local.ollama   # restart
sudo launchctl bootout system/com.local.ollama        # stop/unload
tail -f /var/log/ollama.log
ollama ps                                             # what is loaded, and where (MLX vs GGML)
```

Pull models (see `04-models.md`):

```sh
ollama pull qwen3-coder:30b
ollama run qwen3-coder:30b "say hi" --verbose        # prints tok/s
```

## Option B: llama-server

`brew install llama.cpp` gives `llama-server` built with Metal. Keep it
current (`brew upgrade llama.cpp`); tool-call parsers for new models land
weekly.

Models are plain GGUF files. Use unsloth's `UD-Q4_K_XL` quants:

```sh
mkdir -p ~/models
# -hf downloads to the llama.cpp cache (~/Library/Caches/llama.cpp) on first run
llama-server -hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL \
  --alias qwen3-coder:30b \
  --host 127.0.0.1 --port 8080 \
  -c 131072 -fa on --jinja \
  -ctk q8_0 -ctv q8_0 \
  --temp 1.0 --top-p 0.95 --top-k 40 --min-p 0.01 --repeat-penalty 1.0
```

Daemonise:

```sh
sudo cp files/com.local.llama-server.plist /Library/LaunchDaemons/
sudo sed -i '' "s/USERNAME/$USER/g" /Library/LaunchDaemons/com.local.llama-server.plist
sudo touch /var/log/llama-server.log && sudo chown $USER /var/log/llama-server.log
sudo launchctl bootstrap system /Library/LaunchDaemons/com.local.llama-server.plist
curl -s http://127.0.0.1:8080/v1/models | jq '.data[].id'
```

Serving several models from one process (router mode): put GGUFs in
`~/models` and use `--models-dir ~/models` instead of `-hf ...`; the model is
selected by the `model` field of each request and loaded on demand. Check
`curl :8080/props` to confirm the chat template supports tools.

Flags to know:

- `-c 0` = model's max context; `--fit on` auto-sizes ctx to available memory.
- `--reasoning-format deepseek` / `--reasoning-budget 0` for thinking models.
- `-ngl 99` is the default on Metal (everything on GPU).
- `--parallel 1` (default) - same KV-memory argument as Ollama.

## Expose over the tailnet (both options)

Bind stays on loopback; Tailscale publishes it with TLS and a MagicDNS name:

```sh
sudo tailscale serve --bg --https=443 http://127.0.0.1:11434   # Ollama
sudo tailscale serve --bg --https=8443 http://127.0.0.1:8080   # llama-server (optional 2nd port)
tailscale serve status
```

Clients reach `https://homer.<tailnet>.ts.net/v1` (and `:8443`). Only tailnet
devices can connect; no ports open on the LAN. `serve` config persists across
reboots.

If you prefer plain HTTP without TLS use `--http=80`, or skip `serve` and
bind directly to the tailscale IP (`OLLAMA_HOST=100.x.y.z:11434`) - less tidy
because the IP is baked into the plist.

## Smoke test from a client

```sh
curl -s https://homer.<tailnet>.ts.net/v1/chat/completions \
  -H 'content-type: application/json' \
  -d '{"model":"qwen3-coder:30b","messages":[{"role":"user","content":"hi"}]}' | jq -r '.choices[0].message.content'
```

## Monitoring

```sh
ollama ps                                          # loaded models, VRAM
sudo powermetrics --samplers gpu_power -i 2000     # GPU utilisation
sudo memory_pressure                               # confirm not swapping
top -o mem -stats pid,command,mem,cpu -n 5
```

If `vm_stat` shows heavy swapping, lower `-c`/`OLLAMA_CONTEXT_LENGTH` or pick a
smaller quant. A 64GB Mac comfortable budget: ~50GB model+KV, ~14GB OS/other.
