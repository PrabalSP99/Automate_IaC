resource "aws_instance" "my_instance" {
  ami             = "${var.image_id}"
  instance_type   = "${var.instance_type}"
  count           = 1 # create 1 instance,if not mention it wil create only one
  key_name        = "developer"
  security_groups = [aws_security_group.my_instance_sg.name]

  tags = {
    Name = "My-instance"
  }
}

resource "local_file" "inventory" {
  content  = <<EOT
[aws_instance]
${aws_instance.my_instance[0].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file= ${var.key_address} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOT  
  filename = "${path.module}/ansible/inventory.ini"
}