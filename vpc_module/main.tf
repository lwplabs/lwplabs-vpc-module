

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

locals {
  myapp = "${var.name}-${var.env}-app"
}


## creating my first vpc
resource "aws_vpc" "this" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true" 
    tags = {
    Name = "${var.name}-${var.env}"
    Created = "terraform"
    app     = local.myapp
  }
}

## create public subnet

resource "aws_subnet" "public" {
  count = var.subnet_number

  ## fetch the vpc id from the above created resource
  vpc_id     = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = "true"


  tags = {
    Name = "${var.name}-${var.env}-public-${count.index+1}"
    app     = local.myapp
  }
}


# Subnets private
resource "aws_subnet" "private" {
  count = var.enable_private ? var.subnet_number : 0
  ## fetch the vpc id from the above created resource
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = "false"


  tags = {
    Name = "${var.env}-private-${count.index+1}"
    app     = local.myapp
  }
}




# Internet GW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env}-igw"
    app     = local.myapp
  }
}


# route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod-internet"
  }
}


# route associations public
resource "aws_route_table_association" "prod-public" {
  count = var.subnet_number
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}