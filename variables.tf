variable "yc_token" {
  description = "Yandex.Cloud OAuth token"
  type        = string
}

variable "yc_cloud_id" {
  description = "Yandex.Cloud cloud id"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex.Cloud folder id"
  type        = string
}

variable "yc_zone" {
  description = "Yandex.Cloud zone (например, ru-central1-a)"
  type        = string
  default     = "ru-central1-a"
}

variable "yc_image_id" {
  description = "ID публичного образа Ubuntu 22.04 LTS в Yandex.Cloud"
  type        = string
  default     = "fd817i7o8012578061ra"
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ (ssh-rsa ...)."
  type        = string
} 