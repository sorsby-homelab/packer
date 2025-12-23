packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "talos" {
  iso_url          = "https://github.com/siderolabs/talos/releases/download/${var.talos_version}/metal-amd64.iso"
  iso_checksum     = "${var.talos_checksum}"
  output_directory = "output-talos"
  disk_size        = 20480
  format           = "qcow2"
  memory           = 2048
  cpus             = 2
  boot_wait        = "10s"
  accelerator      = "kvm"
  sockets          = 1
  display          = "none"

  communicator = "none"

  boot_command = [
    "<enter>"
  ]
}

build {
  name    = "talos"
  sources = ["source.qemu.talos"]

  provisioner "shell" {
    inline = [
      "echo 'Talos image build completed'"
    ]
  }
}
