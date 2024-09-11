# create VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-vpc"
  }
}

# create internet gateway
resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.env}-igw"
    }
}

# Public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

    # A map of tags to assign to the resources
    tags = merge({
      Name = "${var.env}-public-${var.azs[count.index]}"},
      var.public_subnets_tags
      )
}

# Private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

    # A map of tags to assign to the resources
    tags = merge({
      Name = "${var.env}-private-${var.azs[count.index]}"},
      var.private_subnets_tags
      )
}

#### NAT gateway ####
# locate public ip first
resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "${var.env}-nat"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.env}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

# public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
      cidr_block     = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.this.id
      }

  tags = {
    Name = "${var.env}-public"
  }
}

# private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this.id
    }

  tags = {
    Name = "${var.env}-private"
  }
}

# Associate route tables with the subnets
# public
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
