#!/usr/bin/env bash
set -euo pipefail

systemctl is-enabled cloud-init >/dev/null
systemctl is-enabled qemu-guest-agent >/dev/null

test -f /etc/cloud/cloud.cfg
test -x /usr/bin/cloud-init

