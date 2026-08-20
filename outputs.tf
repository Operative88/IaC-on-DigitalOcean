output "droplet_ip" {
  description = "Publiczny adres IP Dropletu"
  value       = digitalocean_droplet.web.ipv4_address
}


