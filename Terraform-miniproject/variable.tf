variable "vpc_cidr_block" {
    type = string
    default = "10.0.0.0/16"

}

variable "enable_host_dns" {
    type = bool
    default = true
}

variable "cidr_block_route_and_anywhere" {
    type = string
    default = "0.0.0.0/0"

}

variable "vpc_subnet_count" {
    type = number
    description = "Number of subnets to create"
    default = 3
}

variable "instance_count" {
    type = number
    description = "Number of instances"
    default = 3
}


variable "vpc_subnets_cidr_block" {
    type = list(string)
    description = "CIDR Block for Subnets in VPC"
    default = ["10.0.1.0/24","10.0.2.0/24", "10.0.3.0/24" ]
}


variable "variable_availability_zone" {
    type = list(string)
    description = "Availability zone for VPC"
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}


variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "ami" {
    type = string
    default = "ami-00874d747dde814fa"
}

variable "key_name" {
    type = string
    default = "terra-key"
}

variable "sg_lb_cidr_block" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

variable "sg_instance_cidr_block" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

