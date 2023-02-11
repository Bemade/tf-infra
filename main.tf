provider "aws" {
  region = var.region
}

provider "proxmox" {
  pm_api_url = "https://pve01.durpro.com:8006/api2/json"
  # pm_debug = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}

resource "proxmox_lxc" "basic" {
  target_node  = "pve"
  hostname     = "lxc-basic"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = "BasicLXCContainer"
  unprivileged = true

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "hdd4t0"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }
}
