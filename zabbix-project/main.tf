# main.tf

terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = ">= 0.50.0"
    }
  }
}

# Настройка провайдера Proxmox с API токеном
provider "proxmox" {
  endpoint  = "https://100.83.224.113:8006/"
  api_token = "terraform-provider@pve!provider=c57f7657"
  insecure  = true

  # SSH для провижинеров
  ssh {
    agent    = true
    username = "user"
    private_key = file("~/.ssh/id_ed25519")
  }
}

# Проверка подключения
data "proxmox_virtual_environment_version" "version" {}

# Локальные переменные
locals {
  vm_ip_address = "10.10.10.60"
  vm_gateway    = "10.10.10.1"
  vm_username   = "user"
  ssh_public_key = file("~/.ssh/id_ed25519.pub")
  ssh_private_key = file("~/.ssh/id_ed25519")
}

# Описание ресурса виртуальной машины
resource "proxmox_virtual_environment_vm" "zabbix-server-vm" {
  name        = "zabbix-server-vm"
  description = "Zabbix Server on Docker"
  node_name   = "pve"
  tags        = ["docker", "zabbix", "monitoring"]

  boot_order = ["scsi0"]
  
  agent {
    enabled = true
  }

  clone {
    vm_id = 1000
    full  = true
  }

  cpu {
    cores = 1
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr1"
  }

  disk {
    interface    = "scsi0"
    datastore_id = "local-lvm"
    size         = 40
    file_format  = "raw"
    discard      = "on"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.vm_ip_address}/24"
        gateway = local.vm_gateway
      }
    }
    
    user_account {
      username = local.vm_username
      password = "35795147"
      keys     = [local.ssh_public_key]
    }
    
    dns {
      domain  = "local"
      servers = ["8.8.8.8", "8.8.4.4"]
    }
  }

  operating_system {
    type = "l26"
  }
}

# Отдельный ресурс для провижининга
resource "null_resource" "zabbix_setup" {
  depends_on = [proxmox_virtual_environment_vm.zabbix-server-vm]

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for SSH...'",
      "sleep 30"
    ]
    
    connection {
      type        = "ssh"
      user        = local.vm_username
      private_key = local.ssh_private_key
      host        = local.vm_ip_address
      timeout     = "5m"
    }
  }

  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
    
    connection {
      type        = "ssh"
      user        = local.vm_username
      private_key = local.ssh_private_key
      host        = local.vm_ip_address
    }
  }

  provisioner "file" {
    source      = "setup-zabbix.sh"
    destination = "/tmp/setup-zabbix.sh"
    
    connection {
      type        = "ssh"
      user        = local.vm_username
      private_key = local.ssh_private_key
      host        = local.vm_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-zabbix.sh",
      "sudo /tmp/setup-zabbix.sh",
    ]
    
    connection {
      type        = "ssh"
      user        = local.vm_username
      private_key = local.ssh_private_key
      host        = local.vm_ip_address
    }
  }
}

# Вывод информации
output "proxmox_version" {
  value = data.proxmox_virtual_environment_version.version.version
}

output "vm_ip_address" {
  value = local.vm_ip_address
}

output "vm_ssh_connection" {
  value = "ssh ${local.vm_username}@${local.vm_ip_address}"
}
