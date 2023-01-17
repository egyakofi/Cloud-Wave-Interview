
#### JUMPBOX Servers  ############
resource "aws_security_group" "jumpbox-sg" {
  name        = "jumpbox-sg"
  description = "Allow TLS inbound traffic from rdp and ssh"
  vpc_id      = local.vpc_id

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
       
  tags = {
    Name = "jumpbox-sg"
  }
}

resource "aws_security_group_rule" "ingress-rdp-ssh-inboudrule" {
  for_each = var.rdp_ssh_port

  security_group_id        = aws_security_group.jumpbox-sg.id
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.from_port
  protocol                 = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}


# Create an EC2 instance for jumpbox
resource "aws_instance" "jumpbox-instance" {
  
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  availability_zone = var.jumpbox-az
  vpc_security_group_ids = [aws_security_group.jumpbox-sg.id]
  subnet_id              = aws_subnet.public[0].id
  associate_public_ip_address = true
  tags = {
    Name = "jumpbox-instance"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted  = true

  }
}
