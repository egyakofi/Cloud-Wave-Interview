

locals {
  instance_profile = aws_iam_instance_profile.instance_profile.name
}

data "aws_ami" "ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  description = "Allow alb inbound traffic on port 80"
  vpc_id      = local.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  description = "Allow alb inbound traffic on port 27911"
  vpc_id      = local.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}



resource "aws_security_group_rule" "nginx-ingress-http-inboudrule" {

  security_group_id        = aws_security_group.app-sg.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb-sg.id # alb id  
}

 resource "aws_security_group_rule" "app-ingress-jumpbox-inboudrule" {

  security_group_id        = aws_security_group.app-sg.id
  type                     = "ingress"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jumpbox-sg.id # jumpbox id   
 }

 resource "aws_security_group_rule" "app-ingress-db-app-inboudrule" {

  security_group_id        = aws_security_group.db-sg.id
  type                     = "ingress"
  from_port                = 27911
  to_port                  = 27911
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app-sg.id   
 }

 resource "aws_security_group_rule" "app-ingress-db-jb-inboudrule" {

  security_group_id        = aws_security_group.db-sg.id
  type                     = "ingress"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jumpbox-sg.id   
 }




resource "aws_instance" "app-instance" {
  count                  = length(local.azs)
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app-sg.id]
  #vpc_security_group_ids = [aws_security_group.jumpbox-sg.id]
  iam_instance_profile   = local.instance_profile
  subnet_id              = aws_subnet.private-app.*.id[count.index]
  #security_groups =  ["${aws_security_group.jumpbox-sg.id}"]

  tags = {
    Name = "app-instance"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted  = true

  }
}

resource "aws_instance" "db-instance" {
  count                  = length(local.azs)
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  #vpc_security_group_ids = [aws_security_group.jumpbox-sg.id]
  iam_instance_profile   = local.instance_profile
  subnet_id              = aws_subnet.private-db.*.id[count.index]
  #security_groups =  ["${aws_security_group.jumpbox-sg.id}"]

  tags = {
    Name = "db-instance"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted  = true

  }
}

resource "aws_lb_target_group_attachment" "this" {
count = length(aws_instance.app-instance)
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.app-instance[count.index].id
  port             = 80
}