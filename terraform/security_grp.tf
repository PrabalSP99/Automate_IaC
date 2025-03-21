resource "aws_security_group" "my_instance_sg" {
  name        = "my_security_group"
  description = "Allow SSH and HTTP inbound traffic"


  dynamic "ingress" {
    for_each = var.Ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

