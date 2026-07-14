# Verification

Status: verified.

## RunPod resources

- Account: `account-1` (`Matrix Lab`)
- Private template: `bf739e5uod`
- Network Volume: `f8o2yo0zyf`, 100 GB, `EU-RO-1`

## Live Pod evidence

### RTX 4090

- Pod: `mlc53vxtn6ltxy` (terminated after verification)
- Location: `EU-RO-1`, Secure Cloud
- Device: `NVIDIA GeForce RTX 4090`, 24 GB VRAM
- Runtime: PyTorch `2.8.0+cu128`, ComfyUI `0.27.0`
- ComfyUI `/system_stats`: HTTP 200
- ComfyUI `/object_info`: HTTP 200; UNET, CLIP, VAE, and KSampler nodes present
- JupyterLab `/lab`: HTTP 200
- Volume contained all four expected model files at their exact published sizes

### RTX 5090

- Pod: `aewbnlsxq4cge9` (terminated after verification)
- Location: `EUR-IS-1`, Secure Cloud
- Device: `NVIDIA GeForce RTX 5090`, 32 GB VRAM
- Runtime: PyTorch `2.8.0+cu128`, ComfyUI `0.27.0`
- ComfyUI `/system_stats`: HTTP 200
- ComfyUI `/object_info`: HTTP 200; UNET, CLIP, VAE, and KSampler nodes present
- JupyterLab `/lab`: HTTP 200
- RunPod had no RTX 5090 capacity in either Secure or Community Cloud in
  `EU-RO-1`; the hardware compatibility test therefore used another European
  data center without moving or duplicating the Romania Network Volume.

## Image evidence

- GitHub Actions run: `29334130814`, attempt 2 (`success`)
- Image: `ghcr.io/openfanz/runpod-krea2-comfyui:cu128-torch280-comfyui-0aecac86-20260714`
- OCI index digest: `sha256:41595c73cb21fc5a632387165b2ab8d39fa656681f868c8a75ccd530b1d69b16`
- Linux/amd64 manifest: `sha256:9d3f6d091be653f4964d25ade50d73588a8d2a023d963e20d57a71e6f9b34348`
- Anonymous pull: verified
- ComfyUI commit: `0aecac867d7840b56ad790aa76c5e76e33c74c3d`

Expected release gates:

- [x] public GHCR `linux/amd64` image manifest and immutable digest
- [x] private RunPod template with only `8188/http` and `8888/http`
- [x] 100 GB Network Volume in `EU-RO-1`
- [x] pinned Krea 2 model size and SHA-256 manifest
- [x] live RTX 4090 and RTX 5090 infrastructure checks
- [x] both paid test Pods terminated after evidence capture

This release intentionally contains no Krea 2 workflow JSON files and therefore does not claim completed image-generation inference.
