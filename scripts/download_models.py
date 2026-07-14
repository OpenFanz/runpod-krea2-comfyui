#!/usr/bin/env python3
"""Resumable, checksummed Krea 2 model bootstrap for a RunPod Network Volume."""

from __future__ import annotations

import hashlib
import json
import os
import time
import urllib.request
from pathlib import Path

ROOT = Path(os.environ.get("WORKSPACE", "/workspace"))
STATUS_DIR = ROOT / ".runpod"
STATUS = STATUS_DIR / "models-ready.json"
BASE = "https://huggingface.co/Comfy-Org/Krea-2/resolve/main/"
ASSETS = [
    ("diffusion_models/krea2_raw_fp8_scaled.safetensors", 13141730784, "48cd5d6c100297968349b41a8e77c6591d1dac18a215807f5f25f59e5c54cd61"),
    ("diffusion_models/krea2_turbo_fp8_scaled.safetensors", 13141730784, "eb4dd8c612cfd10f64f25b057e6e6bbcb5737c94a7372177e456dbf7579502f1"),
    ("text_encoders/qwen3vl_4b_fp8_scaled.safetensors", 5242467968, "54bd5144df0bbc25dd6ccadfcb826b521445a1b06ae5a42570bdd2974ca87094"),
    ("vae/qwen_image_vae.safetensors", 253806246, "a70580f0213e67967ee9c95f05bb400e8fb08307e017a924bf3441223e023d1f"),
]


def write_status(ready: bool, files: list[dict], error: str | None = None) -> None:
    STATUS_DIR.mkdir(parents=True, exist_ok=True)
    payload = {"ready": ready, "updatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "files": files}
    if error:
        payload["error"] = error
    temp = STATUS.with_suffix(".tmp")
    temp.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    temp.replace(STATUS)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        while chunk := handle.read(16 * 1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def download(relative: str, expected_size: int) -> Path:
    target = ROOT / "models" / relative
    part = target.with_suffix(target.suffix + ".part")
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists() and target.stat().st_size == expected_size:
        return target
    offset = part.stat().st_size if part.exists() else 0
    if offset > expected_size:
        part.unlink()
        offset = 0
    headers = {"User-Agent": "matrixlab-runpod-krea2/1.0"}
    token = os.getenv("HF_TOKEN") or os.getenv("HUGGINGFACE_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    if offset:
        headers["Range"] = f"bytes={offset}-"
    request = urllib.request.Request(BASE + relative, headers=headers)
    with urllib.request.urlopen(request, timeout=120) as response:
        # Some CDNs ignore Range. Appending a full 200 response to a partial file
        # corrupts the download, so restart cleanly unless the server confirms 206.
        resumed = offset > 0 and response.status == 206
        mode = "ab" if resumed else "wb"
        with part.open(mode) as output:
            while chunk := response.read(16 * 1024 * 1024):
                output.write(chunk)
                output.flush()
    if part.stat().st_size != expected_size:
        raise RuntimeError(f"size mismatch for {relative}: {part.stat().st_size} != {expected_size}")
    part.replace(target)
    return target


def main() -> int:
    results: list[dict] = []
    write_status(False, results)
    try:
        for relative, size, expected_hash in ASSETS:
            path = download(relative, size)
            actual_hash = sha256(path)
            if actual_hash != expected_hash:
                path.unlink(missing_ok=True)
                raise RuntimeError(f"sha256 mismatch for {relative}")
            results.append({"path": str(path.relative_to(ROOT)), "size": size, "sha256": actual_hash, "verified": True})
            write_status(False, results)
        write_status(True, results)
        return 0
    except Exception as exc:
        write_status(False, results, str(exc))
        raise


if __name__ == "__main__":
    raise SystemExit(main())
