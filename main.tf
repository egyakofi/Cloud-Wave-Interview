
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs    = slice(data.aws_availability_zones.available.names, 0, 2)
  vpc_id = aws_vpc.main.id
  required_tags = {
    "ChargeCode" = "04NSOC.SUPP.0000.NSV"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "CloudWave-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  count             = length(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
    tags = {
    Name = "public-sn"
  }
}

resource "aws_subnet" "private-app" {
  count             = length(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr-app[count.index]
  availability_zone = local.azs[count.index]

      tags = {
    Name = "private-app-sn"
  }
}

resource "aws_subnet" "private-db" {
  count             = length(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr-db[count.index]
  availability_zone = local.azs[count.index]

      tags = {
    Name = "private-app-db"
  }
}


resource "aws_route_table" "public" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private-app" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this.id

   
}
     tags = {
    Name = "private-app-rt"
  }
  }

  resource "aws_route_table" "private-db" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this.id

   
}
     tags = {
    Name = "private-db-rt"
  }
  }


###### route table associations
resource "aws_route_table_association" "private-app" {
  count          = length(aws_subnet.private-app)
  subnet_id      = aws_subnet.private-app[count.index].id
  route_table_id = aws_route_table.private-app.id

}

resource "aws_route_table_association" "private-db" {
  count          = length(aws_subnet.private-db)
  subnet_id      = aws_subnet.private-db[count.index].id
  route_table_id = aws_route_table.private-db.id

}

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.main]
  vpc        = true
}