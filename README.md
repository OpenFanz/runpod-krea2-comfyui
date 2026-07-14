# MatrixLab RunPod Krea 2 Runtime

Docker-backed private RunPod Pod template with official ComfyUI, JupyterLab, and persistent Krea 2 RAW/Turbo models. This release intentionally contains no ComfyUI workflow JSON files.

## Runtime

- Base: `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404`
- ComfyUI: official `Comfy-Org/ComfyUI`, pinned to the commit in the image tag/label
- Ports: `8188/http`, `8888/http`
- Volume: 100 GB Network Volume in `EU-RO-1`, mounted at `/workspace`
- JupyterLab is intentionally tokenless.

Models download resumably on first boot. Inspect `/workspace/.runpod/models-ready.json` through Jupyter at `/files/.runpod/models-ready.json`.

