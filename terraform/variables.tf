variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS in us-east-1
}

variable "key_name" {
  description = "SSH key name"
  default     = "id_rsa"
}

variable "docker_image" {
  description = "Docker image to deploy"
  default     = "moe404/booster-django:latest"
}
