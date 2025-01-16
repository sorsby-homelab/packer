# Ubuntu Server Focal
# ---
# Packer Template to create an Ubuntu Server (Focal) on Proxmox

packer {
  required_plugins {
    name = {
      version = "~> 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}


# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-focal" {
  # Proxmox Connection Settings
  proxmox_url = "${var.proxmox_api_url}"
  username = "${var.proxmox_api_token_id}"
  token = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true

  # VM General Settings
  node = "pve1"
  vm_id = "9500"
  vm_name = "ubuntu-server-focal"
  template_description = "Ubuntu 20.04.06, generated on ${timestamp()}"

  boot_iso {
    type = "scsi"
    iso_file = "SynologyNFS:iso/ubuntu-20.04.6-live-server-amd64.iso"
    unmount = true
    iso_checksum = "sha512:33c08e56c83d13007e4a5511b9bf2c4926c4aa12fd5dd56d493c0653aecbab380988c5bf1671dbaea75c582827797d98c4a611f7fb2b131fbde2c677d5258ec9"
  }

  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size = "20G"
    storage_pool = "LVM"
    type = "virtio"
  }

  # VM CPU Settings
  cores = "2"

  # VM Memory Settings
  memory = "2048"

  # VM Network Settings
  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    firewall = "false"
  }

  # VM Cloud-Init Settings
  cloud_init = true
  cloud_init_storage_pool = "SynologyNFS"
  cloud_init_disk_type = "scsi"

  # PACKER Boot Commands
  boot_command = [
    "<esc><wait><esc><wait>",
    "<f6><wait><esc><wait>",
    "<bs><bs><bs><bs><bs>",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "--- <enter>"
  ]
  boot = "c"
  boot_wait = "5s"

  # PACKER Autoinstall Settings
  http_directory = "packer/ubuntu/http"

  ssh_username = "testuser"

  ssh_password = "testpassword"
  ssh_timeout = "40m"
}

# Build Definition to create the VM Template
build {

  name = "ubuntu-server-focal"
  sources = ["source.proxmox-iso.ubuntu-server-focal"]

  provisioner "shell" {
    inline = [ "sudo apt -y remove ubuntu-desktop" ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source = "packer/ubuntu/files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
  }
}
