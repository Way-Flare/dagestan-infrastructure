module "network" {
  source = "./modules/network"
}

module "disks" {
  source = "./modules/disks"
}

resource "yandex_compute_instance" "vm-1" {
  name = "test-stage2"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    disk_id = module.disks.disk-test-stage
  }

  network_interface {
    subnet_id = module.network.subnet-id
    nat       = true
  }

  metadata = {
     user-data = <<-EOT
#cloud-config
datasource:
  Ec2:
    strict_id: false
ssh_pwauth: no
serial-port-enable: 1
users:
- name: fifan
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  ssh_authorized_keys:
  - ${var.ssh-key}
 }
}


resource "yandex_compute_instance" "vm-2" {
  name = "balancer2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = module.disks.disk-balancer
  }

  network_interface {
    subnet_id = module.network.subnet-id
    nat       = true
  }

  metadata = {
    user-data = <<-EOT
#cloud-config
datasource:
  Ec2:
    strict_id: false
ssh_pwauth: no
serial-port-enable: 1
users:
- name: fifan
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  ssh_authorized_keys:
  - ${var.ssh-key}
  }
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}


resource "yandex_compute_instance" "vm-3" {
  name = "monitoring"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    disk_id = module.disks.disk-monitoring
  }

  network_interface {
    subnet_id = module.network.subnet-id
    nat       = true
  }

  metadata = {
     user-data = <<-EOT
#cloud-config
datasource:
  Ec2:
    strict_id: false
ssh_pwauth: no
serial-port-enable: 1
users:
- name: fifan
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  ssh_authorized_keys:
  - ${var.ssh-key}
 }
}
