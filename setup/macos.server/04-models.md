# 04 - Models for 64GB unified memory

Budget rule: weights + KV cache + ~10GB for macOS must stay under 64GB, and
under the `iogpu.wired_limit_mb` you set (56GB). KV cache at q8_0 for a
128k context is roughly 4-8GB for the MoE models below, more for dense ones.

Community consensus (r/LocalLLaMA, HN, 2025-26): **MoE models with ~3B active
params are the sweet spot on Macs** - 60-110 tok/s decode versus 15-25 tok/s
for dense 30B, and tool calling is reliable at 30B+ total params. Small
(<14B) models call tools unreliably and are frustrating in agent loops.

## Recommended

| Model | Ollama tag | Weights | Notes |
|---|---|---|---|
| **Qwen3-Coder-30B-A3B-Instruct** | `qwen3-coder:30b` | ~18GB | Default daily driver. 256k ctx, fast, strong tools. |
| **Qwen3-Coder-Next (80B-A3B)** | `qwen3-coder-next` (check `ollama search`) | ~50GB at 4-bit | Best quality that fits. 4-bit is tight - use ctx <=64k. Needs the wired-limit bump. |
| **Qwen3.5-35B-A3B coding** | `qwen3.5:35b-a3b-coding-nvfp4` | ~20GB | Ollama's MLX/NVFP4 showcase; fastest path on Ollama today. |
| gpt-oss-20b | `gpt-oss:20b` | ~13GB | MXFP4. Fast, decent tools; good "second loaded model" for quick edits. |
| Devstral Small 2 (24B) | `devstral-small-2` | ~14GB | Q4_K_M. Dense; Mistral's agentic coder. Slower decode. |
| Gemma 3 27B | `gemma3:27b` | ~17GB | Q4_K_M. Good general model, weaker tool use. |

## Does not fit / not worth it

- **gpt-oss-120b** MXFP4 = 65GB. No.
- **GLM-4.5-Air (106B-A12B)**: Q2_K is 45GB, Q4 ~60GB. Only a 3-bit fits and
  quality drops; skip on 64GB.
- **Qwen3-32B dense / Llama 3.3 70B**: fit at Q4 (20GB / 40GB) but decode at
  8-20 tok/s - painful in agent loops.

## Sampling for Qwen3-Coder family

`temp 1.0, top_p 0.95, top_k 40, min_p 0.01, repeat_penalty 1.0`
(from unsloth's docs). In Ollama create a Modelfile if you want them baked in:

```sh
cat > /tmp/Modelfile <<'EOF'
FROM qwen3-coder:30b
PARAMETER num_ctx 131072
PARAMETER temperature 1.0
PARAMETER top_p 0.95
PARAMETER top_k 40
PARAMETER min_p 0.01
PARAMETER repeat_penalty 1.0
EOF
ollama create qwen3-coder:30b-oc -f /tmp/Modelfile
```

## Pull everything at once

```sh
export OLLAMA_HOST=http://homer:11434
ollama pull qwen3-coder:30b
ollama pull qwen3.5:35b-a3b-coding-nvfp4
ollama pull gpt-oss:20b
ollama list
```

## Benchmark quickly

```sh
ollama run qwen3-coder:30b --verbose "Write a bash one-liner that counts lines in all .go files"
# look at eval rate: NN tokens/s
```

Expect on M4 Max: Qwen3-Coder-30B Q4 ~70-90 tok/s (GGML) / ~100+ (MLX);
Qwen3-Coder-Next Q4 ~40-60 tok/s; gpt-oss-20b ~90-120 tok/s.
