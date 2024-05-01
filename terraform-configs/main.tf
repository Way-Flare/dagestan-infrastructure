module "network" {
  source = "./modules/network"
}

resource "yandex_compute_disk" "boot-disk-for-test-stage" {
  name     = "boot-disk-for-test-stage"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "30"
  image_id = "fd89n8278rhueakslujo"
}

resource "yandex_compute_disk" "boot-disk-for-balancer" {
  name     = "boot-disk-for-balancer"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "20"
  image_id = "fd89n8278rhueakslujo"
}

resource "yandex_compute_instance" "vm-1" {
  name = "test-stage2"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-for-test-stage.id
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
write_files:
- path: /usr/share/scripts/install-docker.sh
  permissions: '0544'
  content: |
    sudo apt update
    sudo apt install -y docker docker-compose
    sudo docker login --username '${var.backaccount}' --password '${var.backpassword}'
#cloud-config
EOT
 }
}

resource "yandex_compute_instance" "vm-2" {
  name = "balancer2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-for-balancer.id
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
write_files:
- path: /usr/share/scripts/install-docker.sh
  permissions: '0544'
  content: |
    sudo apt update
    sudo apt install -y docker docker-compose
    sudo docker login --username '${var.frontaccount}' --password '${var.frontpassword}'
#cloud-config
EOT
    serial-port-enable = "${file("/home/fifan/Development/dagestan-infrastructure/terraform-configs/serial-port-enable.txt")}"
  }
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}

