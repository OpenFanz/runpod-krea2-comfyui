# Verification

Status: infrastructure build complete; live RunPod deployment is awaiting an
account with the required minimum credit balance.

## Image evidence

- GitHub Actions run: `29333306133` (`success`)
- Image: `ghcr.io/openfanz/runpod-krea2-comfyui:cu128-torch280-comfyui-0aecac86-20260714`
- OCI index digest: `sha256:9c6246fa7dad20588a89c9add3fbf22ad36aadb1ca90bd0fdf47a68363fae54f`
- Linux/amd64 manifest: `sha256:b5f161acb407d97332c84fbf5c8af1fc131701dd6f5df2483dce159da0b21408`
- Anonymous pull: verified
- ComfyUI commit: `0aecac867d7840b56ad790aa76c5e76e33c74c3d`

Expected release gates:

- [x] public GHCR `linux/amd64` image manifest and immutable digest
- private RunPod template with only `8188/http` and `8888/http`
- 100 GB Network Volume in `EU-RO-1`
- [x] pinned Krea 2 model size and SHA-256 manifest
- live RTX 4090 and RTX 5090 infrastructure checks
- both paid test Pods terminated after evidence capture

This release intentionally contains no Krea 2 workflow JSON files and therefore does not claim completed image-generation inference.
