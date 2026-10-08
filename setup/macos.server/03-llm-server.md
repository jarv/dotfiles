# 03 - Ollama inference server

Ollama serves the OpenAI-compatible API directly over Tailscale. Models are
managed with `ollama pull`, and OpenCode connects to `http://homer:11434/v1`.

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

## Install Ollama as a LaunchDaemon

Installed via `setup/macos.server/Brewfile` (`brew install ollama`). Do **not** also install
the Ollama.app; both use port 11434.

Do not use `brew services` here: run with `sudo` it runs as root and puts
models in `/var/root/.ollama`; without `sudo` it is a LaunchAgent and dies
when nobody is logged in. Use the custom LaunchDaemon instead:

```sh
sudo cp files/com.local.ollama.plist /Library/LaunchDaemons/
sudo sed -i '' "s/USERNAME/$USER/g" /Library/LaunchDaemons/com.local.ollama.plist
TS_IP=$(tailscale ip -4)
sudo /usr/libexec/PlistBuddy -c "Set :EnvironmentVariables:OLLAMA_HOST ${TS_IP}:11434" /Library/LaunchDaemons/com.local.ollama.plist
sudo chown root:wheel /Library/LaunchDaemons/com.local.ollama.plist
sudo touch /var/log/ollama.log && sudo chown $USER /var/log/ollama.log
sudo launchctl bootstrap system /Library/LaunchDaemons/com.local.ollama.plist
export OLLAMA_HOST=http://homer:11434
sleep 2
curl -sS --fail-with-body --max-time 10 "$OLLAMA_HOST/api/version"
```

The plist sets:

| Env | Value | Why |
|---|---|---|
| `OLLAMA_HOST` | server's Tailscale IP on port `11434` | set during installation for direct tailnet access |
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

## Direct tailnet access

The installation commands above bind Ollama to the server's Tailscale IPv4
address. Clients use MagicDNS to reach `http://homer:11434/v1`.
Enable Tailscale DNS on clients.

HTTP traffic between devices is encrypted by Tailscale's WireGuard tunnel.
Tailnet access rules must allow port 11434.
Ollama does not listen on the LAN interface.

The source plist defaults to loopback; the installation commands replace that
binding with the server's Tailscale IP. Repeat those substitutions whenever
you reinstall a plist. On Homer, the Tailscale IP is `100.119.78.127`.

Local Ollama CLI commands also need the server address in their environment:

```sh
export OLLAMA_HOST=http://homer:11434
```

## Smoke test from a client

Use Homer's MagicDNS name:

```sh
curl -sS --fail-with-body 'http://homer:11434/v1/chat/completions' \
  -H 'content-type: application/json' \
  -d '{"model":"qwen3-coder:30b","messages":[{"role":"user","content":"hi"}]}' | jq -r '.choices[0].message.content'
```

To check connectivity without loading a model, use:

```sh
curl -sS --fail-with-body --max-time 10 'http://homer:11434/api/version'
```

If a request still fails, use `curl -i` without the `jq` pipe to see the HTTP
status and full response.

## Reboot checks for direct Tailscale access

The installed Ollama daemon binds to Homer's Tailscale IP
(`100.119.78.127:11434`) and clients use `http://homer:11434/v1`.

Ollama may exit if launchd starts it before Tailscale has brought up that
address. The plist's `KeepAlive` retries it with a 10-second throttle. Once
Tailscale is ready, check:

```sh
tailscale status
launchctl print system/com.local.ollama
curl -sS --fail-with-body --connect-timeout 5 --max-time 10 http://homer:11434/api/version
```

`ollama ps` uses localhost unless `OLLAMA_HOST` is set. A CLI connection error
alone does not mean the daemon is stopped:

```sh
export OLLAMA_HOST=http://homer:11434
ollama ps
```

If the API still fails after Tailscale is ready, restart the loaded daemon:

```sh
sudo launchctl kickstart -k system/com.local.ollama
```

## Monitoring

```sh
ollama ps                                          # loaded models, VRAM
sudo powermetrics --samplers gpu_power -i 2000     # GPU utilisation
sudo memory_pressure                               # confirm not swapping
top -o mem -stats pid,command,mem,cpu -n 5
```

If `vm_stat` shows heavy swapping, lower `OLLAMA_CONTEXT_LENGTH` or pick a
smaller quant. A 64GB Mac comfortable budget: ~50GB model+KV, ~14GB OS/other.
