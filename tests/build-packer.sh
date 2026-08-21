#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="packer/rocky9-proxmox.pkr.hcl"
VARS_FILE="${1:-packer/variables.auto.pkrvars.hcl}"

if [[ ! -f "$VARS_FILE" ]]; then
  echo "Vars file not found: $VARS_FILE"
  if [[ "$VARS_FILE" == "packer/variables.auto.pkrvars.hcl" && -f "packer/variables.auto.pkrvars.hcl.example" ]]; then
    echo "Create it from the example, then edit in your real creds:"
    echo "  cp packer/variables.auto.pkrvars.hcl.example packer/variables.auto.pkrvars.hcl"
  fi
  exit 1
fi

packer init "$TEMPLATE"
packer fmt -check -diff "$TEMPLATE"
packer validate -var-file="$VARS_FILE" "$TEMPLATE"
packer build -var-file="$VARS_FILE" "$TEMPLATE"
