terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9"
    }
  }
}

provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = "https://192.168.0.200:8006/api2/json"

  pm_api_token_id = "terraform-prov@pve!new_token_id"
  pm_api_token_secret = "28864412-d12b-4a71-8c66-cf82c96446d9"

  #pm_api_token_id = "root@pam!root_token_id"
  #pm_api_token_secret = "93ac0482-fd7e-4860-be6a-59248918866c"


  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true

  # Logging
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
  pm_timeout = 300000
}

resource "proxmox_vm_qemu" "okd4-bootstrap" {
  vmid = 810
  name = "okd4-bootstrap"
  desc = "Openshift bootstrap"
  memory = 8192
  balloon = 2048
  sockets = 1
  cores = 8
  target_node = "pve"
  iso = var.fedora_core_iso
  onboot = false
  agent = 1
  pool = "openshift"
  numa = false
  scsihw = "virtio-scsi-single"
  bios = "ovmf"
  tablet = false

  vga {
    type = "virtio"
  }

  disk  {
    type  = "virtio"
    storage = "storage-hd2tb"
    size = "120G"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr2"
    firewall = true
    macaddr = "A2:A8:25:9B:05:41"
    queues = 2
  }
}

resource "proxmox_vm_qemu" "okd4-control-plane-1" {
  vmid = 801
  name = "okd4-control-plane-1"
  desc = "Openshift control plane 1"
  memory = 16384
  balloon = 2048
  sockets = 1
  cores = 8
  target_node = "pve"
  iso = var.fedora_core_iso
  onboot = false
  agent = 1
  pool = "openshift"
  numa = false
  scsihw = "virtio-scsi-single"
  bios = "ovmf"
  tablet = false

  vga {
    type = "virtio"
  }

  disk  {
    type  = "virtio"
    storage = "storage-hd2tb"
    size = "120G"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr2"
    firewall = true
    macaddr = "EE:09:1C:69:19:15"
    queues = 2
  }
}

resource "proxmox_vm_qemu" "okd4-control-plane-2" {
  vmid = 802
  name = "okd4-control-plane-2"
  desc = "Openshift control plane 2"
  memory = 16384
  balloon = 2048
  sockets = 1
  cores = 8
  target_node = "pve"
  iso = var.fedora_core_iso
  onboot = false
  agent = 1
  pool = "openshift"
  numa = false
  scsihw = "virtio-scsi-single"
  bios = "ovmf"
  tablet = false

  vga {
    type = "virtio"
  }

  disk  {
    type  = "virtio"
    storage = "storage-hd2tb"
    size = "120G"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr2"
    firewall = true
    macaddr = "16:DC:51:2D:19:0D"
    queues = 2
  }
}

resource "proxmox_vm_qemu" "okd4-control-plane-3" {
  vmid = 803
  name = "okd4-control-plane-3"
  desc = "Openshift control plane 3"
  memory = 16384
  balloon = 2048
  sockets = 1
  cores = 8
  target_node = "pve"
  iso = var.fedora_core_iso
  onboot = false
  agent = 1
  pool = "openshift"
  numa = false
  scsihw = "virtio-scsi-single"
  bios = "ovmf"
  tablet = false

  vga {
    type = "virtio"
  }

  disk  {
    type  = "virtio"
    storage = "storage-hd2tb"
    size = "120G"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr2"
    firewall = true
    macaddr = "2E:D8:7A:25:B9:CE"
    queues = 2
  }
}

resource "proxmox_vm_qemu" "okd4-compute-1" {
  vmid = 804
  name = "okd4-compute-1"
  desc = "Openshift compute 1"
  memory = 16384
  balloon = 2048
  sockets = 1
  cores = 8
  target_node = "pve"
  iso = var.fedora_core_iso
  onboot = false
  agent = 1
  pool = "openshift"
  numa = false
  scsihw = "virtio-scsi-single"
  bios = "ovmf"
  tablet = false

  vga {
    type = "virtio"
  }

  disk  {
    type  = "virtio"
    storage = "storage-hd2tb"
    size = "120G"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr2"
    firewall = true
    macaddr = "A2:E9:7A:12:14:BB"
    queues = 2
  }
}

resource "proxmox_vm_qemu" "okd4-compute-2" {
  vmid = 805
  name = "okd4-compute-2"
  desc = "Openshift compute 1"
  memory = 16384
  balloon = 2048
  sockets = 1
  cores = 8
  target_node = "pve"
  iso = var.fedora_core_iso
  onboot = false
  agent = 1
  pool = "openshift"
  #qemu_os = "linux"
  numa = false
  scsihw = "virtio-scsi-single"
  bios = "ovmf"

  vga {
    type = "virtio"
  }

  disk  {
    type  = "virtio"
    storage = "storage-hd2tb"
    size = "120G"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr2"
    firewall = true
    macaddr = "F6:F0:BD:FD:ED:FD"
    queues = 2
  }
}

resource "proxmox_vm_qemu" "okd4-compute-3" {
  vmid = 806
  name = "okd4-compute-3"
  desc = "Openshift compute 3"
  memory = 16384
  balloon = 2048
  sockets = 1
  cores = 8
  target_node = "pve"
  iso = var.fedora_core_iso
  onboot = false
  agent = 1
  pool = "openshift"
  #qemu_os = "linux"
  numa = false
  scsihw = "virtio-scsi-single"
  bios = "ovmf"

  vga {
    type = "virtio"
  }

  disk  {
    type  = "virtio"
    storage = "storage-hd2tb"
    size = "120G"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr2"
    firewall = true
    macaddr = "56:DF:11:89:FB:7B"
    queues = 2
  }
}
