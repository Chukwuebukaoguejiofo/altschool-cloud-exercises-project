# Create an Application Load Balancer

resource "aws_lb" "terraform-load-balancer" {
    name                = "terraform-load-balancer"
    internal            = false
    load_balancer_type  = "application"
    security_groups     = [aws_security_group.terraform-load-balancer-sg.id]
    subnets             = aws_subnet.subnets[*].id
    #enable_cross_zone_load_balancing = true
    enable_deletion_protection = false
 
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

#Create the listener rule

resource "aws_lb_listener_rule" "terraform-listener-rule" {
    listener_arn = aws_lb_listener.terraform-listener.arn
    priority = 1

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.terraform-target-group.arn
    }

    condition {
      host_header {
        values = ["terraform-test.miniproject.name.ng"]
      }
    }
}

# Attach the target group to the load balancer

resource "aws_lb_target_group_attachment" "terraform-target-group-attachment1" {
    count            = var.instance_count
    target_group_arn = aws_lb_target_group.terraform-target-group.arn
    target_id        = aws_instance.terraform_instances[count.index].id
    port             = 80
}

