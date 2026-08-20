# wgraj klucz publiczny do DigitalOcean
resource "digitalocean_ssh_key" "default" {
  name       = var.ssh_key_name
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Utwórz Droplet
resource "digitalocean_droplet" "web" {
  image    = "ubuntu-24-04-x64"
  name     = "terraform-droplet"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  ssh-keys = [digitalocean_ssh_key.default.fingerprint]

  # test połączenia SSH zaraz po utworzeniu
  provisioner "remote-exec" {
    inline = ["echo 'Droplet gotowy!'"]

    connection {
      host	  = self.ipv4_address
      user        = "root"
      type        = "ssh
      private_key = file(var.pvt_key)
      timeout     = "2m"
    }
  }
}
