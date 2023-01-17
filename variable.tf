variable "region" {
  type        = string
  description = "AWS region to deploy into."
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block to use for the VPC.  Defaults to 10.0.0.0/16."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = list(any)
  description = "CIDR block to use for the VPC.  Defaults to 10.0.0.0/16."
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidr-app" {
  type        = list(any)
  description = "CIDR block to use for the VPC.  Defaults to 10.0.0.0/16."
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr-db" {
  type        = list(any)
  description = "CIDR block to use for the VPC.  Defaults to 10.0.0.0/16."
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}


variable "http_https_port" {
  type        = map(any)
  description = "http and https port"
  default = {
    http_port = {
      from_port = 80
      to_port   = 80
    }
    https_port = {
      from_port = 443
      to_port   = 443
    }

    
  }
}

variable "rdp_ssh_port" {
  type        = map(any)
  description = "rdp and ssh port"
  default = {
    rdp_port = {
      from_port = 3389
      to_port   = 3389
    }
    ssh_port = {
      from_port = 22
      to_port   = 22
    }
  }

}

variable "db_port" {
  type        = map(any)
  description = "traffic from appserver to dbserver"
  default = {
    rdp_port = {
      from_port = 27911
      to_port   = 27911
    }
    
  }

}

variable "instance_type" {
    default = "t2.micro"
  
}

variable "jumpbox-az" {
    default = "us-east-1a"
  
}