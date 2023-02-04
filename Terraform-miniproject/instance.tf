#Create an UBUNTU Server 
resource "aws_instance" "terraform_instances" {
 count             = var.instance_count
 ami               = var.ami
 instance_type     = var.instance_type
 availability_zone = var.variable_availability_zone[count.index]
 security_groups   = [aws_security_group.EC2-instance-security-group.id]
 key_name          = var.key_name
 subnet_id         = aws_subnet.subnets[count.index].id
 tags = {
    Name = "instances"
  }

}

# resource "null_resource" "ssh_local_remote_connection" {
#   count            = var.instance_count
#   provisioner "remote-exec" {

#     inline = ["sudo echo 'ssh is ready!'"]
    
  
#     connection {
#     type                    = "ssh"
#     user                    = "ubuntu"
#     private_key             = file("/home/cyberterminal/altschool-cloud-exercises-project/terraform-ansible/terra-key.pem")
#     host                    = aws_instance.terraform_instances[count.index].public_ip
#   }
#   }

#    provisioner "local-exec" {
#     command = "ansible-playbook -i ${aws_instance.terraform_instances[count.index].public_ip}, --private-key ${"/home/cyberterminal/altschool-cloud-exercises-project/terraform-ansible/terra-key.pem"} /home/cyberterminal/altschool-cloud-exercises-project/terraform-ansible/main.yml"
#   }
# }


  


