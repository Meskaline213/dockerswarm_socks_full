output "shop_vm_external_ip" {
  description = "Внешний IP-адрес ВМ с интернет-магазином и логированием"
  value       = yandex_compute_instance.sockshop_vm.network_interface[0].nat_ip_address
}

output "monitoring_vm_external_ip" {
  description = "Внешний IP-адрес ВМ с мониторингом"
  value       = yandex_compute_instance.monitoring_vm.network_interface[0].nat_ip_address
} 