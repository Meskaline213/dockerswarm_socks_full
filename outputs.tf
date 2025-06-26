output "swarm_manager_external_ip" {
  description = "Внешний IP-адрес менеджера Swarm-кластера"
  value       = yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address
}

output "swarm_worker1_external_ip" {
  description = "Внешний IP-адрес первого воркера Swarm-кластера"
  value       = yandex_compute_instance.swarm_worker1.network_interface[0].nat_ip_address
}

output "swarm_worker2_external_ip" {
  description = "Внешний IP-адрес второго воркера Swarm-кластера"
  value       = yandex_compute_instance.swarm_worker2.network_interface[0].nat_ip_address
}

output "sock_shop_url" {
  description = "URL для доступа к Sock Shop"
  value       = "http://${yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address}"
}

output "grafana_url" {
  description = "URL для доступа к Grafana"
  value       = "http://${yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address}:3000"
}

output "prometheus_url" {
  description = "URL для доступа к Prometheus"
  value       = "http://${yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address}:9090"
} 