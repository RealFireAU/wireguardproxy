

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
    ansible = {
      version = "~> 1.2.0"
      source  = "ansible/ansible"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

# ED25519 key
resource "tls_private_key" "ed25519" {
  algorithm = "ED25519"
}
data "aws_ami" "al" {
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

resource "aws_key_pair" "key" {
  key_name   = tls_private_key.ed25519.id
  public_key = tls_private_key.ed25519.public_key_openssh
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.al.id
  instance_type   = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.name.id ]
  tags = {
    Name = "HelloWorld"
  }

  key_name = aws_key_pair.key.key_name
}

resource "ansible_host" "web" {
  name   = aws_instance.web.tags["Name"]
  groups = ["main"]

  variables = {
    ansible_user                 = "ec2-user",
    ansible_ssh_private_key_file = tls_private_key.ed25519.private_key_openssh
  }
}

resource "local_sensitive_file" "private_key_pem" {
  content  = tls_private_key.ed25519.private_key_openssh
  filename = "${path.module}/key.pem"
}

resource "ansible_playbook" "name" {
  playbook   = "playbook.yaml"
  name       = aws_instance.web.public_dns
#   verbosity = 6
  groups     = ansible_host.web.groups
  replayable = true
  extra_vars = {
    ansible_user                 = "ec2-user"
    ansible_ssh_private_key_file = "${path.module}/key.pem"
  }
}

output "name" {
  value = ansible_playbook.name.ansible_playbook_stdout
}


resource "aws_security_group" "name" {
  name        = "ssh-sg"
  description = "Allow SSH"

  ingress = [{
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
    self = false
    security_groups = []
    ipv6_cidr_blocks = []
    prefix_list_ids = []
  }]

  egress = [ {
    to_port = 0
    from_port = 0
    protocol = "all"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = ""
    ipv6_cidr_blocks = [  ]
    prefix_list_ids = []
    security_groups = [  ]
    self = false
  } ]

}