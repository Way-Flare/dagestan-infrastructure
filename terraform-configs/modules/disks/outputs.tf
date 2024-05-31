output "disk-test-stage" {
  value = yandex_compute_disk.boot-disk-for-test-stage.id
}

output "disk-balancer" {
  value = yandex_compute_disk.boot-disk-for-balancer.id
}

output "disk-monitoring" {
  value = yandex_compute_disk.boot-disk-for-monitoring.id
}

output "disk-nexus" {
  value = yandex_compute_disk.boot-disk-for-nexus.id
}

