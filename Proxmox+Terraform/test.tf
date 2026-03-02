terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.60.1"  # или последняя версия
    }
  }
}

provider "proxmox" {
  endpoint = "https://100.83.224.113:8006"
  api_token = "root@pam!tf_token=88a631a0-badb-41f1-82bd-ea41f2ad6907"
  insecure = true
  
  ssh {
    agent = true
  }
}

# Первая виртуальная машина
resource "proxmox_virtual_environment_vm" "vm_1" {  # имя ресурса изменилось!
  name        = "adminguide-vm-01"
  node_name   = "pve"           # теперь node_name вместо target_node
  clone {
    vm_id = 1000  # или ID вашего шаблона u22s-tpl
  }
  
  # Настройки CloudInit
  initialization {
    user_account {
      username = "user"
      keys = [file("~/.ssh/id_ed25519.pub")]
    }
    
    ip_config {
      ipv4 {
        address = "10.10.10.121/24"
        gateway = "10.10.10.1"
      }
    }
  }
  
  cpu {
    cores = 2
    sockets = 1
  }
  
  memory {
    dedicated = 4096
  }
  
  # Диск
  disk {
    interface = "scsi0"
    size = 32
    datastore_id = "local-lvm"
    file_format = "raw"
  }
  
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }
}

# Вторая виртуальная машина - аналогично
resource "proxmox_virtual_environment_vm" "vm_2" {
  name        = "adminguide-vm-02"
  node_name   = "pve"
  clone {
    vm_id = 1000
  }
  
  initialization {
    user_account {
      username = "user"
      keys = [file("~/.ssh/id_ed25519.pub")]
    }
    
    ip_config {
      ipv4 {
        address = "10.10.10.122/24"
        gateway = "10.10.10.1"
      }
    }
  }
  
  cpu {
    cores = 2
    sockets = 1
  }
  
  memory {
    dedicated = 4096
  }
  
  disk {
    interface = "scsi0"
    size = 32
    datastore_id = "local-lvm"
    file_format = "raw"
  }
  
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }
}

output "vm_1_info" {
  value = {
    name = proxmox_virtual_environment_vm.vm_1.name
    ipv4_address = proxmox_virtual_environment_vm.vm_1.ipv4_addresses[0]
  }
}

output "vm_2_info" {
  value = {
    name = proxmox_virtual_environment_vm.vm_2.name
    ipv4_address = proxmox_virtual_environment_vm.vm_2.ipv4_addresses[0]
  }
}
