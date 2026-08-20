# IaC on DigitalOcean

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![DigitalOcean](https://img.shields.io/badge/DigitalOcean-0080FF?style=for-the-badge&logo=digitalocean&logoColor=white)](https://www.digitalocean.com/)
[![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)

A starter project demonstrating how to provision a DigitalOcean Droplet with [Terraform](https://www.terraform.io/) and configure it with [Ansible](https://www.ansible.com/), using Infrastructure as Code from end to end.

## Table of Contents

- [What It Is](#what-it-is)
- [Caveats and Limitations](#caveats-and-limitations)
- [Preview in Action](#preview-in-action)
- [Requirements](#requirements)
- [How to Provision and Configure](#how-to-provision-and-configure)
- [Project Structure](#project-structure)
- [Advanced Usage: Configuring the Server with Ansible](#advanced-usage-configuring-the-server-with-ansible)
  - [Building the Inventory from Terraform Output](#building-the-inventory-from-terraform-output)
- [Cleaning Up](#cleaning-up)
- [Acknowledgements](#acknowledgements)
- [License](#license)

## What It Is

This repository contains a [Terraform](https://developer.hashicorp.com/terraform) configuration that provisions a [Droplet](https://www.digitalocean.com/products/droplets) on [DigitalOcean](https://www.digitalocean.com/). This project was implemented according to the [roadmap.sh IaC on DigitalOcean project guide](https://roadmap.sh/projects/iac-digitalocean).

When applied, Terraform uploads an SSH public key to your DigitalOcean account and creates an Ubuntu Droplet with a public IP address and SSH access. As a stretch goal, an [Ansible](https://www.ansible.com/) playbook then connects to the Droplet over SSH and configures it — installing and starting nginx and setting up a firewall.

## Caveats and Limitations

- **Billing Applies:** A running Droplet incurs charges on DigitalOcean. Destroy the infrastructure when you are done to avoid unexpected costs.
- **Sensitive Values:** The API token lives in `terraform.tfvars` and the state file. Both must be kept out of version control (see [`.gitignore`](.gitignore)).
- **Root SSH Access:** The default configuration connects as `root`. For production use you would create a dedicated, unprivileged user.
- **Terraform and Ansible Required:** Terraform provisions the infrastructure; Ansible (run from your local machine) configures it.

## Preview in Action

After `terraform apply`, Terraform prints the Droplet's public IP:

```bash
$ terraform output droplet_ip
"167.172.108.183"
```

After running the Ansible playbook, visiting `http://<DROPLET_IP>` in a browser serves the default nginx welcome page, confirming the server was configured successfully.

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install) installed on your system.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed on your system (for the stretch goal).
- A [DigitalOcean account](https://www.digitalocean.com/) and a personal access token with **Read** and **Write** scopes.
- An SSH key pair (e.g. `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`).

## How to Provision and Configure

1. **Clone the repository** and navigate to the project directory:

   ```bash
   git clone https://github.com/your-username/iac-digitalocean.git
   cd iac-digitalocean
   ```

2. **Create your `terraform.tfvars`** with your token and private key path:

   ```hcl
   do_token = "dop_v1_your_token_here"
   pvt_key  = "~/.ssh/id_ed25519"
   ```

3. **Initialize Terraform** (downloads the DigitalOcean provider):

   ```bash
   terraform init
   ```

4. **Review and apply** the plan:

   ```bash
   terraform plan
   terraform apply
   ```

5. **SSH into the Droplet** using your private key:

   ```bash
   ssh -i ~/.ssh/id_ed25519 root@$(terraform output -raw droplet_ip)
   ```

## Project Structure

```text
.
├── provider.tf        # Terraform and DigitalOcean provider configuration
├── variables.tf       # Input variable declarations
├── main.tf            # SSH key and Droplet resources
├── outputs.tf         # Exposes the Droplet's public IP
├── terraform.tfvars   # Your token and key path (gitignored)
├── playbook.yml       # Ansible playbook for server configuration
├── inventory.ini      # Ansible inventory (generated from Terraform output)
├── .gitignore         # Excludes secrets and state files
└── README.md          # Project documentation
```

## Advanced Usage: Configuring the Server with Ansible

Terraform builds the infrastructure; Ansible configures it. The playbook updates packages, installs nginx and ufw, opens the SSH and HTTP ports, and ensures nginx is running:

```yaml
- name: Konfiguracja serwera
  hosts: web
  become: true

  tasks:
    - name: Aktualizacja listy pakietow
      apt:
        update_cache: yes

    - name: Instalacja nginx i ufw
      apt:
        name:
          - nginx
          - ufw
        state: present

    - name: Zezwol na SSH w firewallu
      ufw:
        rule: allow
        port: "22"
        proto: tcp

    - name: Zezwol na HTTP w firewallu
      ufw:
        rule: allow
        port: "80"
        proto: tcp

    - name: Wlacz firewall
      ufw:
        state: enabled

    - name: Upewnij sie ze nginx dziala
      service:
        name: nginx
        state: started
        enabled: true
```

### Building the Inventory from Terraform Output

Generate the Ansible inventory directly from Terraform's output so you never copy the IP by hand:

```bash
cat > inventory.ini << EOF
[web]
$(terraform output -raw droplet_ip) ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_ed25519
EOF
```

Verify connectivity, then run the playbook:

```bash
ansible -i inventory.ini web -m ping
ansible-playbook -i inventory.ini playbook.yml
```

Once it finishes, open `http://<DROPLET_IP>` to see the default nginx page.

## Cleaning Up

To avoid ongoing charges, destroy the infrastructure when you are finished:

```bash
terraform destroy
```

Your `.tf` files, `playbook.yml`, and `inventory.ini` remain on disk, so the whole environment can be recreated at any time with `terraform apply`.

## Acknowledgements

- Project idea and requirements provided by [roadmap.sh DevOps Projects](https://roadmap.sh/projects/iac-digitalocean).
- [How To Use Terraform with DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean).
- [DigitalOcean Terraform provider documentation](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs).

## License

Distributed under the [MIT License](LICENSE).
