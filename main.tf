terraform {
  required_version = ">= 0.13"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.80.0"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}

# --- Сеть и подсеть ---

resource "yandex_vpc_network" "network_1" {
  name = "network-1"
}

resource "yandex_vpc_subnet" "subnet_1" {
  name           = "subnet-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# --- Образ ОС ---

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# --- Виртуальные машины (count = 2) ---

resource "yandex_compute_instance" "web" {
  count = 2
  name  = "web-vm-${count.index + 1}"
  zone  = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      packages:
        - nginx
      runcmd:
        - systemctl enable nginx
        - systemctl start nginx
      users:
        - name: ubuntu
          sudo: 'ALL=(ALL) NOPASSWD:ALL'
          ssh_authorized_keys:
            - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjaK6VmfAa3NzlLHCzNrSiDRNwLt59906zryv19KpjIUc8DNySUjj+yS16ojlWCJhGefyMTxXj1SaLW2ARxk6hmtKwu6i2pstlmSqjOMZ7le8Tz8Vt/Vwzta3+Xi0+7J6KRXExkIPUqKXoCz4K1qgyWtfN23OvRTqyFBiH2KOur5Rbr0xM2Cs0huQx9H5fbtHvIYBV8LQSVXwPXEjrfrePR/XoUJpdHwTuejFbZNSMIYvGD29ut/MlnXHUS8ly7SpqqQK5dyblDvoSlX21MaorJP9wGfB5uR5uCHVvVhHD7Hxkijj7imyYHEFbEnu9KvpWdbJkf3DMu5hXZpLa1T6N andrey.ogay@NewName
    EOF
  }
}

# --- Целевая группа (Target Group) ---

resource "yandex_lb_target_group" "web_tg" {
  name      = "web-target-group"
  folder_id = yandex_compute_instance.web[0].folder_id

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id = yandex_vpc_subnet.subnet_1.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

# --- Сетевой балансировщик (Network Load Balancer) ---

resource "yandex_lb_network_load_balancer" "lb" {
  name = "web-lb"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web_tg.id

    healthcheck {
      name = "http-healthcheck"
      http_options {
        port = 80
        path = "/"
      }
      interval            = 2
      timeout             = 1
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }
}

# --- Output-переменные ---

output "lb_external_ip" {
  value = tolist(yandex_lb_network_load_balancer.lb.listener)[0].external_address_spec[*].address
}
