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
    storage = "hdd4t0"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }
}
