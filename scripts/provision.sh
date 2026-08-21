#!/usr/bin/env bash
set -euo pipefail

if ! command -v dnf >/dev/null 2>&1; then
  echo "dnf is required and was not found."
  exit 1
fi

dnf -y makecache
dnf -y update
dnf -y install cloud-init qemu-guest-agent openscap-scanner scap-security-guide

systemctl enable qemu-guest-agent
systemctl enable cloud-init cloud-config cloud-final cloud-init-local

dnf -y autoremove
dnf clean all
rm -rf /var/cache/dnf/*

