## network

#### VPC
resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags {
        Name = "fargate-vpc"
    }
}

#### Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "Checkdead Internet Gateway"
    }
}

#### NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = "${aws_eip.nat_eip.id}"
    subnet_id = "${aws_subnet.front_subnet.0.id}"
}

resource "aws_eip" "nat_eip" {
    vpc      = true
}

#### Security Group
resource "aws_default_security_group" "default" {
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        protocol  = "-1"
        self = "true"
        from_port = 0
        to_port   = 0
    }

    egress {
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 0
     }
}

#### Subnets
resource "aws_subnet" "front_subnet" {
    count = 2
    cidr_block = "${element(var.front_subnet_cidr, count.index)}"
    availability_zone = "${element(var.zones, count.index)}"
    map_public_ip_on_launch = "false"
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "front-subnet${count.index + 1 }"
    }
}


resource "aws_subnet" "app_subnet" {
    count = 2
    cidr_block = "${element(var.app_subnet_cidr, count.index)}"
    availability_zone = "${element(var.zones, count.index)}"
    map_public_ip_on_launch = "false"
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "app-subnet${count.index + 1 }"
    }
}

#### Route table
resource "aws_route_table" "front_route_table" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }

    tags {
        Name = "route-table"
    }
}

resource "aws_route_table" "nat_route_table" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
    }

    tags {
        Name = "nat-route-table"
    }
}

resource "aws_route_table_association" "route_table_association" {
    count = 2
    subnet_id = "${element(aws_subnet.front_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.front_route_table.id}"
}

resource "aws_route_table_association" "nat_route_table_association" {
    count = 2
    subnet_id = "${element(aws_subnet.app_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.nat_route_table.id}"
}

resource "aws_security_group" "http" {
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "http"
    }
}
