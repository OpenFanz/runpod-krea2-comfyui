FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

ARG COMFYUI_REF=0aecac867d7840b56ad790aa76c5e76e33c74c3d
LABEL org.opencontainers.image.source="https://github.com/OpenFanz/runpod-krea2-comfyui" \
      org.opencontainers.image.description="RunPod ComfyUI + JupyterLab runtime for Krea 2 RAW and Turbo" \
      io.matrixlab.comfyui.commit="${COMFYUI_REF}"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    COMFYUI_ROOT=/opt/ComfyUI \
    WORKSPACE=/workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git jq rsync tini \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --filter=blob:none https://github.com/Comfy-Org/ComfyUI.git /opt/ComfyUI \
    && git -C /opt/ComfyUI fetch --depth 1 origin "${COMFYUI_REF}" \
    && git -C /opt/ComfyUI checkout --detach "${COMFYUI_REF}" \
    && test "$(git -C /opt/ComfyUI rev-parse HEAD)" = "${COMFYUI_REF}"

RUN python -m pip install --no-cache-dir -r /opt/ComfyUI/requirements.txt \
    && python -m pip install --no-cache-dir "jupyterlab>=4.4,<5" "notebook>=7.4,<8"

COPY scripts /app
RUN chmod +x /app/run.sh /app/start.sh

EXPOSE 8188 8888
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/app/run.sh"]
