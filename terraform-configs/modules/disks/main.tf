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

resource "yandex_compute_disk" "boot-disk-for-monitoring" {
  name     = "boot-disk-for-monitoring"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "20"
  image_id = "fd89n8278rhueakslujo"
}

resource "yandex_compute_disk" "boot-disk-for-nexus" {
  name     = "boot-disk-for-nexus"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "20"
  image_id = "fd89n8278rhueakslujo"
}
