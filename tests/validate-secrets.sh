#!/usr/bin/env bash
set -euo pipefail

required_secrets=(
  PROXMOX_USERNAME
  PROXMOX_TOKEN
  SSH_USERNAME
  PACKER_SSH_PASSWORD
)

required_variables=(
  PROXMOX_URL
  PROXMOX_NODE
  PROXMOX_ISO_URL
)

missing_secrets=()
for key in "${required_secrets[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    missing_secrets+=("${key}")
  fi
done

missing_variables=()
for key in "${required_variables[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    missing_variables+=("${key}")
  fi
done

if (( ${#missing_secrets[@]} > 0 || ${#missing_variables[@]} > 0 )); then
  if (( ${#missing_secrets[@]} > 0 )); then
    echo "Missing required environment secrets:"
    printf '  - %s\n' "${missing_secrets[@]}"
  fi
  if (( ${#missing_variables[@]} > 0 )); then
    echo "Missing required environment variables:"
    printf '  - %s\n' "${missing_variables[@]}"
  fi
  exit 1
fi

if [[ "${SSH_USERNAME}" != "root" ]]; then
  echo "Invalid SSH_USERNAME: expected 'root' for kickstart-based install, got '${SSH_USERNAME}'"
  exit 1
fi
