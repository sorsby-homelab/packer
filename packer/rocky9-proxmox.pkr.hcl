packer {
  required_version = ">= 1.10.0"

  required_plugins {
    proxmox = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_url" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "proxmox_token" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_insecure_tls" {
  type    = bool
  default = false
}

variable "proxmox_iso_url" {
  type = string
}

variable "proxmox_iso_checksum" {
  type    = string
  default = "file:https://download.rockylinux.org/pub/rocky/9/isos/x86_64/CHECKSUM"
}

variable "proxmox_iso_storage_pool" {
  type    = string
  default = "local"
}

variable "template_name_prefix" {
  type    = string
  default = "rocky9-cloudinit"
}

variable "vm_bridge" {
  type    = string
  default = "vmbr0"
}

variable "vm_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

locals {
  build_suffix  = formatdate("YYYYMMDD-hhmmss", timestamp())
  template_name = "${var.template_name_prefix}-${local.build_suffix}"
}

source "proxmox-iso" "rocky9" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  node                     = var.proxmox_node
  insecure_skip_tls_verify = var.proxmox_insecure_tls

  template_name        = local.template_name
  template_description = "Rocky Linux 9 cloud-init template (CIS L1), built by Packer on ${timestamp()}"

  http_directory = "packer/http"
  boot_wait      = "10s"
  boot_command = [
    "<up><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky9.ks.cfg<enter>"
  ]

  boot_iso {
    type             = "ide"
    iso_url          = var.proxmox_iso_url
    iso_checksum     = var.proxmox_iso_checksum
    iso_storage_pool = var.proxmox_iso_storage_pool
    iso_download_pve = false
    unmount          = true
  }

  os              = "l26"
  cores           = 2
  sockets         = 1
  memory          = 2048
  cpu_type        = "host"
  numa            = true
  scsi_controller = "virtio-scsi-pci"

  cloud_init              = true
  cloud_init_storage_pool = var.vm_storage_pool

  network_adapters {
    bridge = var.vm_bridge
    model  = "virtio"
  }

  disks {
    type         = "scsi"
    disk_size    = "20G"
    storage_pool = var.vm_storage_pool
  }

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "45m"
}

build {
  sources = ["source.proxmox-iso.rocky9"]

  provisioner "shell" {
    script = "scripts/provision.sh"
  }

  provisioner "shell" {
    script = "scripts/hardening.sh"
  }

  provisioner "shell" {
    script = "scripts/smoke.sh"
  }
}
