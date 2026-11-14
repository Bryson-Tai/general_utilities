#! /bin/bash

set -euo pipefail

# Required: STORAGE_ACCOUNT_NAME, FILE_SHARE_NAME (from `tofu output storage`)
LLM_MODEL_NAME="${LLM_MODEL_NAME:-Qwen/Qwen2.5-7B-Instruct-AWQ}"
MODEL_DIR="models--${LLM_MODEL_NAME//\//--}"

# Download LLM Model with Hugging Face CLI, cached in $HOME/.cache/huggingface/hub
hf download "$LLM_MODEL_NAME"

export AZCOPY_AUTO_LOGIN_TYPE=AZCLI

# Copy to Azure File Share
azcopy copy \
    --recursive \
    --follow-symlinks \
    "$HOME/.cache/huggingface/hub/${MODEL_DIR}/" \
    "https://${STORAGE_ACCOUNT_NAME}.file.core.windows.net/${FILE_SHARE_NAME}"
