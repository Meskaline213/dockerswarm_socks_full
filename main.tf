terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# Сеть
resource "yandex_vpc_network" "default" {
  name = "default"
}

# Подсеть
resource "yandex_vpc_subnet" "default" {
  name           = "default"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.5.0.0/24"]
  zone           = var.yc_zone
}

# Security Group для Swarm Manager
resource "yandex_vpc_security_group" "swarm_manager_sg" {
  name        = "swarm-manager-sg"
  description = "Security group for Swarm Manager"
  network_id  = yandex_vpc_network.default.id

  ingress {
    description    = "Allow SSH"
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTP"
    port           = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTPS"
    port           = 443
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow Swarm API"
    port           = 2377
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow join token HTTP"
    port           = 8080
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow Grafana"
    port           = 3000
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow Prometheus"
    port           = 9090
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Swarm node communication TCP"
    port           = 7946
    protocol       = "TCP"
    v4_cidr_blocks = ["10.5.0.0/24"]
  }

  ingress {
    description    = "Swarm node communication UDP"
    port           = 7946
    protocol       = "UDP"
    v4_cidr_blocks = ["10.5.0.0/24"]
  }

  ingress {
    description    = "Overlay network traffic (VXLAN)"
    port           = 4789
    protocol       = "UDP"
    v4_cidr_blocks = ["10.5.0.0/24"]
  }

  ingress {
    description    = "Ping (ICMP)"
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.5.0.0/24"]
  }

  egress {
    from_port      = 0
    to_port         = 65535
    protocol        = "ANY"
    v4_cidr_blocks  = ["0.0.0.0/0"]
  }
}

# Security Group для Swarm Workers
resource "yandex_vpc_security_group" "swarm_worker_sg" {
  name        = "swarm-worker-sg"
  description = "Security group for Swarm Workers"
  network_id  = yandex_vpc_network.default.id

  ingress {
    description    = "Allow SSH"
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTP"
    port           = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTP Alt"
    port           = 8080
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow Swarm API"
    port           = 2377
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Swarm node communication TCP"
    port           = 7946
    protocol       = "TCP"
    v4_cidr_blocks = ["10.5.0.0/24"]
  }

  ingress {
    description    = "Swarm node communication UDP"
    port           = 7946
    protocol       = "UDP"
    v4_cidr_blocks = ["10.5.0.0/24"]
  }

  ingress {
    description    = "Overlay network traffic (VXLAN)"
    port           = 4789
    protocol       = "UDP"
    v4_cidr_blocks = ["10.5.0.0/24"]
  }

  ingress {
    description    = "Ping (ICMP)"
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.5.0.0/24"]
  }

  egress {
    from_port      = 0
    to_port         = 65535
    protocol        = "ANY"
    v4_cidr_blocks  = ["0.0.0.0/0"]
  }
}

# Swarm Manager
resource "yandex_compute_instance" "swarm_manager" {
  name = "swarm-manager"
  zone = var.yc_zone

  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_image_id
      size     = 30
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.default.id
    security_group_ids = [yandex_vpc_security_group.swarm_manager_sg.id]
    nat                = true
  }

  metadata = {
    user-data = file("${path.module}/cloud-init-manager.yaml")
    ssh-keys  = "ubuntu:${var.ssh_public_key}"
  }
}

# Swarm Worker 1
resource "yandex_compute_instance" "swarm_worker1" {
  name = "swarm-worker1"
  zone = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.default.id
    security_group_ids = [yandex_vpc_security_group.swarm_worker_sg.id]
    nat                = true
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init-worker.yaml", {
      manager_ip = yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address
    })
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# Swarm Worker 2
resource "yandex_compute_instance" "swarm_worker2" {
  name = "swarm-worker2"
  zone = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.default.id
    security_group_ids = [yandex_vpc_security_group.swarm_worker_sg.id]
    nat                = true
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init-worker.yaml", {
      manager_ip = yandex_compute_instance.swarm_manager.network_interface[0].nat_ip_address
    })
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
} 