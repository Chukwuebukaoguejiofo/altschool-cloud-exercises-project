# Create a security group for the load balancer
resource "aws_security_group" "terraform-load-balancer-sg" {
  name        = "terraform-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.terraform-vpc.id
  
   ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.sg_lb_cidr_block
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.sg_lb_cidr_block
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.sg_lb_cidr_block
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
    cidr_blocks      = var.sg_instance_cidr_block
    security_groups = [aws_security_group.terraform-load-balancer-sg.id]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.sg_instance_cidr_block
    security_groups = [aws_security_group.terraform-load-balancer-sg.id]
  }


  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.sg_instance_cidr_block
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.sg_instance_cidr_block
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform-ec2-security group"
  }
}