# Rocky Linux Cloud-Init Image Pipeline (Proxmox + Packer)

This repository builds a hardened Rocky Linux cloud-init template for Proxmox using Packer and GitHub Actions.

## What this pipeline does

- Builds a Rocky Linux template directly from ISO (`proxmox-iso` builder).
- Applies package updates during provisioning.
- Applies CIS Rocky Linux Level 1 hardening with OpenSCAP remediation.
- Runs:
  - Packer formatting/validation checks.
  - OpenSCAP compliance evaluation during image build.
- Rebuilds weekly via GitHub Actions schedule.

## Repository layout

- `packer/rocky9-proxmox.pkr.hcl`: Packer template.
- `packer/variables.auto.pkrvars.hcl.example`: Example variable file.
- `scripts/provision.sh`: OS updates and base provisioning.
- `scripts/hardening.sh`: CIS Level 1 remediation and compliance check.
- `scripts/smoke.sh`: Post-hardening runtime smoke tests.
- `.github/workflows/ci.yml`: PR/manual validation + build workflow.
- `.github/workflows/weekly-rebuild.yml`: Weekly image rebuild workflow.
- `tests/validate-packer.sh`: Packer init/fmt/validate checks.
- `tests/validate-secrets.sh`: Checks required environment secrets/variables before build.

## Required GitHub Actions environment setup

The CI and weekly rebuild workflows use the `pve1` environment. Set these in that environment (or as repository-level values if you intentionally want shared defaults).

### Required environment secrets

- `PROXMOX_USERNAME` (token ID format, e.g. `packer@pve!packer-token`)
- `PROXMOX_TOKEN` (the Proxmox API token secret)
- `SSH_USERNAME` (`root` for this kickstart-based build)
- `PACKER_SSH_PASSWORD` (password used by Packer SSH during initial ISO install)

### Required environment variables

- `PROXMOX_URL` (e.g. `https://pve.example.com:8006/api2/json`)
- `PROXMOX_NODE` (e.g. `pve`)
- `PROXMOX_ISO_URL` (e.g. `https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9-latest-x86_64-minimal.iso`)

### Optional environment variables

- `PROXMOX_ISO_CHECKSUM` (default `file:https://download.rockylinux.org/pub/rocky/9/isos/x86_64/CHECKSUM`)
- `PROXMOX_INSECURE_TLS` (`true`/`false`, default `false`)
- `PROXMOX_BRIDGE` (default `vmbr0`)
- `PROXMOX_STORAGE_POOL` (default `local-lvm`)
- `TEMPLATE_NAME_PREFIX` (default `rocky9-cloudinit`)
- `PROXMOX_ISO_STORAGE_POOL` (default `local`)

## Local usage

1. Install Packer.
2. Copy the example var-file and fill values:
   - `cp packer/variables.auto.pkrvars.hcl.example packer/variables.auto.pkrvars.hcl`
3. Run:
   - `bash tests/validate-packer.sh`
   - `packer build -var-file=packer/variables.auto.pkrvars.hcl packer/rocky9-proxmox.pkr.hcl`

## Notes

- This pipeline no longer depends on a pre-existing clone source VM.
- It performs unattended Rocky Linux installation via `packer/http/rocky9.ks.cfg`.
- ISO is downloaded directly on the Proxmox node (`iso_download_pve = true`) from Rocky's `latest` URL.
- OpenSCAP content is auto-detected for Rocky 9 (`ssg-rocky9-ds.xml` or `ssg-rhel9-ds.xml`).
- This template uses API token auth (`username` as `user@realm!tokenid` plus `token` secret), not account password auth.
