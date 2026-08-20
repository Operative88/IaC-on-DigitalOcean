  provisioner "remote-exec" {
    inline = ["echo 'Droplet gotowy!'"]

    connection {
      host        = self.ipv4_address
      user        = "root"
      type        = "ssh"
      private_key = file(var.pvt_key)
      timeout     = "2m"
    }
  }
