#!/usr/bin/env bash
set -euo pipefail

mkdir -p \
  /workspace/.runpod \
  /workspace/input \
  /workspace/output \
  /workspace/user \
  /workspace/logs \
  /workspace/models/diffusion_models \
  /workspace/models/text_encoders \
  /workspace/models/vae \
  /workspace/models/loras

python - <<'PY'
import json, os, platform, subprocess
from pathlib import Path

def command(args):
    try:
        return subprocess.check_output(args, text=True, stderr=subprocess.STDOUT, timeout=20).strip()
    except Exception as exc:
        return f"unavailable: {exc}"

try:
    import torch
    torch_info = {"version": torch.__version__, "cuda": torch.version.cuda, "available": torch.cuda.is_available(), "device": torch.cuda.get_device_name(0) if torch.cuda.is_available() else None}
except Exception as exc:
    torch_info = {"error": str(exc)}

data = {
    "podId": os.getenv("RUNPOD_POD_ID"),
    "dataCenter": os.getenv("RUNPOD_DC_ID"),
    "cudaEnvironment": os.getenv("CUDA_VERSION"),
    "python": platform.python_version(),
    "torch": torch_info,
    "nvidiaSmi": command(["nvidia-smi", "--query-gpu=name,driver_version,memory.total", "--format=csv,noheader"]),
    "comfyuiCommit": command(["git", "-C", "/opt/ComfyUI", "rev-parse", "HEAD"]),
    "workspaceWritable": os.access("/workspace", os.W_OK),
}
Path("/workspace/.runpod/system-info.json").write_text(json.dumps(data, indent=2), encoding="utf-8")
PY

python /app/download_models.py > /workspace/logs/model-download.log 2>&1 &
MODEL_PID=$!

cd /workspace
jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --ServerApp.root_dir=/workspace \
  --ServerApp.token='' \
  --IdentityProvider.token='' \
  --ServerApp.password='' \
  --ServerApp.allow_origin='*' \
  > /workspace/logs/jupyter.log 2>&1 &
JUPYTER_PID=$!

cd /opt/ComfyUI
python main.py \
  --listen 0.0.0.0 \
  --port 8188 \
  --enable-cors-header '*' \
  --extra-model-paths-config /app/extra_model_paths.yaml \
  --input-directory /workspace/input \
  --output-directory /workspace/output \
  --user-directory /workspace/user \
  > /workspace/logs/comfyui.log 2>&1 &
COMFY_PID=$!

cleanup() {
  kill "$MODEL_PID" "$JUPYTER_PID" "$COMFY_PID" 2>/dev/null || true
  wait "$MODEL_PID" "$JUPYTER_PID" "$COMFY_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

while kill -0 "$JUPYTER_PID" 2>/dev/null && kill -0 "$COMFY_PID" 2>/dev/null; do
  sleep 5
done

echo "A primary service exited. Inspect /workspace/logs." >&2
exit 1

