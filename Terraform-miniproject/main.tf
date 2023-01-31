terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#Create a VPC
resource "aws_vpc" "terraform-vpc" {
 cidr_block = "10.0.0.0/16"
 enable_dns_hostnames = true
 tags = {
  Name = "production"
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
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public route table"
  }
}

# Our first Public subnet of VPC
resource "aws_subnet" "terraform-public-subnet1" {
 vpc_id  = aws_vpc.terraform-vpc.id
 cidr_block = "10.0.1.0/24"
 map_public_ip_on_launch = true
 availability_zone = "us-east-1a"

 tags = {
  Name = "terraform-public-subnet1"
 }
}

# Our Second Public subnet of VPC
resource "aws_subnet" "terraform-public-subnet2" {
 vpc_id  = aws_vpc.terraform-vpc.id
 cidr_block = "10.0.2.0/24"
 map_public_ip_on_launch = true
 availability_zone = "us-east-1b"

 tags = {
  Name = "terraform-public-subnet2"
 }
}

# Associate Public subnet 1 with public route table
resource "aws_route_table_association" "terraform-public-subnet1-association" {
  subnet_id      = aws_subnet.terraform-public-subnet1.id
  route_table_id = aws_route_table.terraform-public-route-table.id
}

# Associate Public subnet 2 with public route table
resource "aws_route_table_association" "terraform-public-subnet2-association" {
  subnet_id      = aws_subnet.terraform-public-subnet2.id
  route_table_id = aws_route_table.terraform-public-route-table.id
}

# Create a Network ACL
resource "aws_network_acl" "terraform-network_acl" {
    vpc_id = aws_vpc.terraform-vpc.id
    subnet_ids = [aws_subnet.terraform-public-subnet1.id, aws_subnet.terraform-public-subnet2.id]

    ingress {
        rule_no = 100
        protocol = "-1"
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }

    egress {
        rule_no = 100
        protocol = "-1"
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
}


# Create a security group for the load balancer
resource "aws_security_group" "terraform-load-balancer-sg" {
  name        = "terraform-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.terraform-vpc.id
  
   ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
# Create a Security Group for port 443, 80 and 22 for EC2 Instance
resource "aws_security_group" "EC2-instance-security-group" {
  name        = "allow_web_traffic_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for private instances"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups = [aws_security_group.terraform-load-balancer-sg.id]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups = [aws_security_group.terraform-load-balancer-sg.id]
  }


  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform-ec2-security group"
  }
}

#Create an UBUNTU Server 
resource "aws_instance" "terraform-1" {
 ami               = "ami-00874d747dde814fa" 
 instance_type     = "t2.micro"
 availability_zone = "us-east-1a"
 security_groups   = [aws_security_group.EC2-instance-security-group.id]
 key_name          = "terra-key"
 subnet_id         = aws_subnet.terraform-public-subnet1.id

 tags = {
    Name = "terraform-1"
    source = "terraform"
 }
}

resource "aws_instance" "terraform-2" {
 ami               = "ami-00874d747dde814fa" 
 instance_type     = "t2.micro"
 availability_zone = "us-east-1b"
 security_groups   = [aws_security_group.EC2-instance-security-group.id]
 key_name          = "terra-key"
 subnet_id         = aws_subnet.terraform-public-subnet2.id

 tags = {
    Name = "terraform-2"
    source= "terraform"
 }
}

resource "aws_instance" "terraform-3" {
 ami               = "ami-00874d747dde814fa" 
 instance_type     = "t2.micro"
 availability_zone = "us-east-1a"
 security_groups   = [aws_security_group.EC2-instance-security-group.id]
 key_name          = "terra-key"
 subnet_id         = aws_subnet.terraform-public-subnet1.id

 tags = {
    Name = "terraform-3"
    source = "terraform"
 }
}

# Create a file to store the IP address of the Instances

resource "local_file" "Ip_address" {
 
    filename = "/home/cyberterminal/altschool-cloud-exercises-project/Terraform-miniproject/terraform-ansible/inventories/dev/hosts"
    content  = <<EOT
${aws_instance.terraform-1.public_ip}
${aws_instance.terraform-2.public_ip}
${aws_instance.terraform-3.public_ip}
 EOT

}

# Create an Application Load Balancer

resource "aws_lb" "terraform-load-balancer" {
    name                = "terraform-load-balancer"
    internal            = false
    load_balancer_type  = "application"
    security_groups     = [aws_security_group.terraform-load-balancer-sg.id]
    subnets             = [aws_subnet.terraform-public-subnet1.id, aws_subnet.terraform-public-subnet2.id]
    #enable_cross_zone_load_balancing = true
    enable_deletion_protection = false
    depends_on = [aws_instance.terraform-1, aws_instance.terraform-2, aws_instance.terraform-3]

}

#Create the target group

resource "aws_lb_target_group" "terraform-target-group" {
    name                = "terraform-target-group"
    target_type         = "instance"
    port                = 80
    protocol            = "HTTP"
    vpc_id              = aws_vpc.terraform-vpc.id

    health_check {
      path               = "/"
      protocol           = "HTTP"
      matcher            ="200"
      interval           = 15
      timeout            = 3
      healthy_threshold  = 3

    }
}

# Create the Listener
resource "aws_lb_listener" "terraform-listener" {
    load_balancer_arn  =  aws_lb.terraform-load-balancer.arn
    port               = "80"
    protocol           = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.terraform-target-group.arn
    }
}

# Create the listener rule

resource "aws_lb_listener_rule" "terraform-listener-rule" {
    listener_arn = aws_lb_listener.terraform-listener.arn
    priority = 1

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.terraform-target-group.arn
    }

    condition {
      path_pattern {
        values = ["/"]
      }
    }
}

# Attach the target group to the load balancer

resource "aws_lb_target_group_attachment" "terraform-target-group-attachment1" {
    target_group_arn = aws_lb_target_group.terraform-target-group.arn
    target_id        = aws_instance.terraform-1.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "terraform-target-group-attachment2" {
    target_group_arn = aws_lb_target_group.terraform-target-group.arn
    target_id        = aws_instance.terraform-2.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "terraform-target-group-attachment3" {
    target_group_arn = aws_lb_target_group.terraform-target-group.arn
    target_id        = aws_instance.terraform-3.id
    port             = 80
}


