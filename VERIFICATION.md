# Verification

Status: implementation in progress.

Expected release gates:

- public GHCR `linux/amd64` image manifest and immutable digest
- private RunPod template with only `8188/http` and `8888/http`
- 100 GB Network Volume in `EU-RO-1`
- verified Krea 2 model size and SHA-256 manifest
- live RTX 4090 and RTX 5090 infrastructure checks
- both paid test Pods terminated after evidence capture

This release intentionally contains no Krea 2 workflow JSON files and therefore does not claim completed image-generation inference.
