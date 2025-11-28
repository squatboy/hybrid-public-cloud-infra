#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

#--------------------------------------------------------------
# Internet Gateway
#--------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#--------------------------------------------------------------
# Public Subnets (Multi-AZ)
# - ALB, NAT Gateway 배치용
# - EKS용 태그 포함 (kubernetes.io/role/elb)
#--------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "${var.project_name}-public-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
    Tier                                            = "public"
  }
}

#--------------------------------------------------------------
# Private Subnets (Multi-AZ)
# - EKS 워커 노드, Lambda, 내부 서비스용
# - EKS용 태그 포함 (kubernetes.io/role/internal-elb)
#--------------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                            = "${var.project_name}-private-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
    Tier                                            = "private"
  }
}

#--------------------------------------------------------------
# Elastic IP for NAT Gateway
# - 비용 절감을 위해 단일 NAT GW 사용 (HA 필요시 AZ별 생성)
#--------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  # NAT Gateway 삭제 전에 EIP가 먼저 삭제되지 않도록
  depends_on = [aws_internet_gateway.igw]
}

#--------------------------------------------------------------
# NAT Gateway
# - Private Subnet의 아웃바운드 인터넷 접속용
# - AZ-a의 Public Subnet에 배치 (비용 절감)
#--------------------------------------------------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # 첫 번째 Public Subnet (AZ-a)

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

#--------------------------------------------------------------
# Public Route Table
# - 인터넷 게이트웨이로 기본 라우팅
#--------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Public Subnet들을 Public Route Table에 연결
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#--------------------------------------------------------------
# Private Route Table
# - NAT Gateway로 기본 라우팅
# - VPN 경로는 Route Propagation으로 자동 추가됨
#--------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Private Subnet들을 Private Route Table에 연결
resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
