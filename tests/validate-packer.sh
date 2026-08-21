#!/usr/bin/env bash
set -euo pipefail

packer init packer/rocky9-proxmox.pkr.hcl
packer fmt -check -diff packer/rocky9-proxmox.pkr.hcl
packer validate \
  -var "proxmox_url=https://example.invalid:8006/api2/json" \
  -var "proxmox_username=packer@pve!packer-token" \
  -var "proxmox_token=placeholder" \
  -var "proxmox_node=pve" \
  -var "proxmox_iso_url=https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9-latest-x86_64-minimal.iso" \
  -var "proxmox_iso_checksum=sha256:0000000000000000000000000000000000000000000000000000000000000000" \
  -var "proxmox_iso_storage_pool=local" \
  -var "ssh_password=placeholder" \
  packer/rocky9-proxmox.pkr.hcl
