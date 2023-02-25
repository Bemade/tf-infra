provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = "https://pve01.durpro.com:8006/api2/json"
  pm_otp = ""
}

resource "proxmox_lxc" "basic" {
  target_node  = "pve01"
  hostname     = "lxc-basic"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = "BasicLXCContainer"
  unprivileged = true

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "hdd4to"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }
}

resource "proxmox_vm_qemu" "cloudinit-test" {
    name = "terraform-test-vm"
    desc = "A test for using terraform and cloudinit"

    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve01"

    # The destination resource pool for the new VM
    pool = "pool0"

    # The template name to clone this vm from
    clone = "debian10ci"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 2048
    scsihw = "lsi"

    # Setup the disk
    disk {
        size = 8G
        type = "virtio"
        storage = "local"
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
        tag = 256
    }

    # Setup the ip address using cloud-init.
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=192.168.10.20/24,gw=192.168.10.1"
    sshkeys = <<EOF
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEsNLo8NDKurxAIO4gbLS7Xqttc3Chjr88SY6uYAhiAT benoit@vezina.biz
    EOF
}
