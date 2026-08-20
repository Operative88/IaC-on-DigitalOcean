variable "do_token" {
  description = "Token API DigitalOcean"
  type	      = string
  sensitive   = true
}

variable "pvt_key" {
  description = "ścieżka do prywatnego klucza SSH"
  type        = string
}

variable "ssh_key_name" {
  description = "Nazwa klucza SSH w DigitalOcean"
  type        = string
  default     = "terraform-key"
}

