provider "aws" {
  alias = "requester"
}

provider "aws" {
  alias = "accepter"
}

data "aws_vpc" "requester" {
  provider = aws.requester
  id = var.requester_vpc_id
}

data "aws_vpc" "accepter" {
  provider = aws.accepter
  id = var.accepter_vpc_id
}

data "aws_region" "requester" {
  provider = aws.requester
}

data "aws_region" "accepter" {
  provider = aws.accepter  
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "requester" {
  provider = aws.requester

  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  peer_region = data.aws_region.accepter.name

  tags = {
    Name = data.aws_region.accepter.name
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  auto_accept               = true

  tags = {
    Name = data.aws_region.requester.name
  }
}

# Ensure DNS resolution across VPCs
resource "aws_vpc_peering_connection_options" "requester" {
  provider = aws.requester

  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "requester" {
  provider = aws.requester
  count    = length(var.requester_route_tables)

  route_table_id            = var.requester_route_tables[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
}   

resource "aws_route" "accepter" {
  provider = aws.accepter
  count    = length(var.accepter_route_tables)

  route_table_id            = var.accepter_route_tables[count.index]
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
}
