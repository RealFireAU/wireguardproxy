# AWS WireGuard Proxy

This project uses Terraform to provision an EC2 instance in AWS and Ansible to configure WireGuard and set up port forwarding rules on the instance.

## Prerequisites

- Terraform
- Ansible
- AWS account and credentials

## Usage

1. Clone the repository:

\```
git clone https://github.com/RealFireAU/wireguardproxy.git
cd aws-wireguard-proxy
\```

2. Configure Terraform with your AWS credentials.

3. Customize the Terraform variables in `variables.tf` according to your requirements, such as the AWS region, instance type, and port to forward.

4. Initialize Terraform:

\```
terraform init
\```

5. Plan and apply the Terraform configuration:

\```
terraform plan
terraform apply
\```

This will create an EC2 instance and run the ansible playbook

8. Connect to the WireGuard VPN using the generated configuration file.

9. You can now access on-premise resources through the AWS IP address and forwarded port.

## Configuration

- `variables.tf`: Define Terraform variables for customization.
- `main.tf`: Terraform configuration for creating the EC2 instance.
- `playbook.yml`: Ansible playbook for configuring WireGuard and port forwarding.
- `roles/wireguard/tasks/main.yml`: Ansible tasks for setting up WireGuard. [TODO]
- `roles/portforwarding/tasks/main.yml`: Ansible tasks for configuring iptables port forwarding. [TODO]