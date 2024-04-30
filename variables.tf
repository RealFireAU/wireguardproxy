# 
# AWS realted variables
# 
variable "aws_region" {
  description = "Defines the AWS region resouces will be created in"
  default     = "ap-southeast-2"
}

variable "aws_instance_type" {
  description = "Defines the instance size used for the VM, it does not need to be large as it only proxies traffic"
  default     = "t2.micro"
}

# 
# General variables
# 
variable "key_algorithm" {
  description = "Defines the algorithm used for the SSH/TLS key used to access the ec2-user"
  default     = "ED25519"
}