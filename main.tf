provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

resource "yandex_vpc_network" "default" {}

resource "yandex_vpc_subnet" "default" {
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_compute_instance" "sockshop_vm" {
  name        = "sockshop-vm"
  platform_id = "standard-v1"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.default.id
    nat            = true
    security_group_ids = [yandex_vpc_security_group.sockshop_sg.id]
  }

  metadata = {
    user-data = file("cloud-init.yaml")
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "monitoring_vm" {
  name        = "monitoring-vm"
  platform_id = "standard-v1"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.default.id
    nat            = true
    security_group_ids = [yandex_vpc_security_group.monitoring_sg.id]
  }

  metadata = {
    user-data = file("cloud-init-monitoring.yaml")
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "yandex_vpc_security_group" "sockshop_sg" {
  name       = "sockshop-sg"
  network_id = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    description    = "Allow HTTPS"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "monitoring_sg" {
  name       = "monitoring-sg"
  network_id = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow Grafana"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    description    = "Allow Prometheus"
    port           = 9090
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    description    = "Allow Alertmanager"
    port           = 9093
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    description    = "Allow Node Exporter"
    port           = 9100
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
} 