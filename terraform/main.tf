provider "aws" {
    region = "ap-south-1"
}



resource "aws_security_group" "my_instance_sg"{
    name = "my_security_group"
    description = "Allow SSH and HTTP inbound traffic"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (adjust as needed)
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Allow HTTP
    }

     ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Allow FastAPI traffic
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "my_instance" {
    ami ="ami-00bb6a80f01f03502"
    instance_type = "t2.micro"
    count = 1   # create 1 instance,if not mention it wil create only one
    key_name = "developer"
    security_groups = [aws_security_group.my_instance_sg.name]

    tags ={
        Name= "My-instance"
    }
}

resource "local_file" "inventory" {
  content  = templatefile("${path.module}/../Ansible/inventory.tpl", { public_ip = aws_instance.my_instance[0].public_ip })
  filename = "${path.module}/../Ansible/inventory.ini"
}