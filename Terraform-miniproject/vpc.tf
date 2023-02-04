#Create a VPC
resource "aws_vpc" "terraform-vpc" {
 cidr_block = var.vpc_cidr_block
 enable_dns_hostnames = var.enable_host_dns
 tags = {
  Name = "terraform-vpc"
 }
}

#Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "Main"
  }
}

#Create a Public Route Table
resource "aws_route_table" "terraform-public-route-table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = var.cidr_block_route_and_anywhere
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public route table"
  }
}

# Subnet of VPC
resource "aws_subnet" "subnets" {
 count = var.vpc_subnet_count
 vpc_id  = aws_vpc.terraform-vpc.id
 cidr_block = var.vpc_subnets_cidr_block[count.index]
 map_public_ip_on_launch = true
 availability_zone = var.variable_availability_zone[count.index]
 
  tags = {
    Name = "vpc subnets"
  }
}


# Associate Public subnets  with public route table
resource "aws_route_table_association" "rta-subnets" {
  count = var.vpc_subnet_count
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.terraform-public-route-table.id
}


# Create a Network ACL
resource "aws_network_acl" "terraform-network_acl" {
    count = var.vpc_subnet_count
    vpc_id = aws_vpc.terraform-vpc.id
    subnet_ids = [aws_subnet.subnets[count.index].id]

    ingress {
        rule_no = 100
        protocol = "-1"
        action = "allow"
        cidr_block = var.cidr_block_route_and_anywhere
        from_port = 0
        to_port = 0
    }

    egress {
        rule_no = 100
        protocol = "-1"
        action = "allow"
        cidr_block = var.cidr_block_route_and_anywhere
        from_port = 0
        to_port = 0
    }
}
