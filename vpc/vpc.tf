resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-main-vpc"
  })  
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id 

tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })  
}

#CREATING PUBLIC SUBNETS--------------------------------------------------------------------

resource "aws_subnet" "public_subnet_az_2a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_cidr_block[0]
  availability_zone =var.availability_zone[0]

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-2a"
  })  
}

resource "aws_subnet" "public_subnet_az_2b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_cidr_block[1]
  availability_zone =var.availability_zone[1 ]
  
  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-2b"
  })  
}

#creating private subnets------------------------------------------------------------------
resource "aws_subnet" "private_subnet_az_2a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_cidr_block[0]
  availability_zone =var.availability_zone[0]

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-2a"
  })  
}

resource "aws_subnet" "private_subnet_az_2b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_cidr_block[1]
  availability_zone =var.availability_zone[1]

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-2b"
  })  
}

#creating db subnets-------------------------------------------------------------------------------
resource "aws_subnet" "db_subnet_az_2a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_cidr_block[0]
  availability_zone =var.availability_zone[0]

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}db-subnet-az-2a"
  })  
}

resource "aws_subnet" "db_subnet_az_2b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_cidr_block[1]
  availability_zone =var.availability_zone[1]

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}db-subnet-az-2b "
  })  
}

#creating public route table---------------------------------------------------------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })  
}

#create subnet assocations for public subnets-----------------------------------------------------------
resource "aws_route_table_association" "rt_association_public_subnet_az_2a" {
  subnet_id      = aws_subnet.public_subnet_az_2a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rt_association_public_subnet_az_2b" {
  subnet_id      = aws_subnet.public_subnet_az_2b.id
  route_table_id = aws_route_table.public_rt.id
}

#creating an elastic EIP for AZ 2A----------------------------------------------------------------------------------
resource "aws_eip" "eip_az_2a" {
  domain   = "vpc"

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-2a"
  })  
}

#creating a nat gateway for AZ 2A--------------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gw_az_2a" {
  allocation_id = aws_eip.eip_az_2a.id
  subnet_id     = aws_subnet.public_subnet_az_2a.id

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-2a"
  })  

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_2a, aws_subnet.public_subnet_az_2a]
}

#creating a private route table for az-2a-----------------------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az_2a.id
  }

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt"
  })  
}

#create subnet assocations for private subnets-----------------------------------------------------------
resource "aws_route_table_association" "rt_association_private_subnet_az_2a" {
  subnet_id      = aws_subnet.private_subnet_az_2a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "rt_association_eb_subnet_az_2a" {
  subnet_id      = aws_subnet.db_subnet_az_2a.id
  route_table_id = aws_route_table.private_rt.id
}

#creating an elastic EIP for AZ 2B----------------------------------------------------------------------------------
resource "aws_eip" "eip_az_2b" {
  domain   = "vpc"

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-2b"
  })  
}

#creating a nat gateway for AZ 2A--------------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gw_az_2b" {
  allocation_id = aws_eip.eip_az_2b.id
  subnet_id     = aws_subnet.public_subnet_az_2b.id

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-2b"
  })  

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_2b, aws_subnet.public_subnet_az_2b]
}

#creating a private route table for az-2b-----------------------------
resource "aws_route_table" "private_rt_az_2b" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az_2b.id
  }

  tags = merge(var.tags, {
     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-2b"
  })  
}

#create subnet assocations for private subnets az 2b-----------------------------------------------------------
resource "aws_route_table_association" "rt_association_private_subnet_az_2b" {
  subnet_id      = aws_subnet.private_subnet_az_2b.id
  route_table_id = aws_route_table.private_rt_az_2b.id
}

resource "aws_route_table_association" "rt_association_db_subnet_az_2b" {
  subnet_id      = aws_subnet.db_subnet_az_2b.id
  route_table_id = aws_route_table.private_rt_az_2b.id
}