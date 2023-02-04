# Create a file to store the IP address of the Instances

# resource "local_file" "Ip_address" {
 
#     filename = "/home/cyberterminal/altschool-cloud-exercises-project/Terraform-miniproject/terraform-ansible/inventories/dev/hosts"
#     content  = <<EOT
# ${aws_instance.terraform_instances[0].public_ip}
# ${aws_instance.terraform_instances[1].public_ip}
# ${aws_instance.terraform_instances[2].public_ip}
#  EOT

# }

output "ip_address_instances_1" {
    value = aws_instance.terraform_instances[0].public_ip
}


output "ip_address_instances_2" {
    value = aws_instance.terraform_instances[1].public_ip
}

output "ip_address_instances_3" {
    value = aws_instance.terraform_instances[2].public_ip
}


// load balancer outputs

output "elastic_load_balancer_dns_name" {
    value = aws_lb.terraform-load-balancer.dns_name
}


