# 
# Create TLS keys
# 
resource "tls_private_key" "ssh_key" {
  algorithm = var.key_algorithm
}

resource "aws_key_pair" "key" {
  key_name   = tls_private_key.ssh_key.id
  public_key = tls_private_key.ssh_key.public_key_openssh
  depends_on = [tls_private_key.ssh_key]
}

resource "local_sensitive_file" "private_key_pem" {
  content    = tls_private_key.ssh_key.private_key_openssh
  filename   = "${path.module}/key.pem"
  depends_on = [tls_private_key.ssh_key]
}

# 
# Create VM
# 
resource "aws_security_group" "name" {
  name        = "ssh-sg"
  description = "Allow SSH"

  ingress = [{
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    self             = false
    security_groups  = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
  }]

  egress = [{
    to_port          = 0
    from_port        = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}

data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "instance" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.name.id]
  key_name               = aws_key_pair.key.key_name
}

# 
# Ansible 
# 
resource "ansible_playbook" "name" {
  playbook   = "playbook.yaml"
  name       = aws_instance.instance.public_dns
  replayable = true
  extra_vars = {
    ansible_user                 = "ec2-user"
    ansible_ssh_private_key_file = "${path.module}/key.pem"
    ansible_host_key_checking = "False"
  }

  depends_on = [local_sensitive_file.private_key_pem]
}

resource "terraform_data" "TempFile-delete" {
  provisioner "local-exec" {
    command = "rm ${path.module}/key.pem"
    quiet = true
  }

  depends_on = [ansible_playbook.name, tls_private_key.ssh_key, local_sensitive_file.private_key_pem]
}
