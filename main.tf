
# Provider platform defenition

provider "aws" {
  region  = var.aws_region
  profile = "default"
}

# Resources to be created in Provider platform

resource "aws_vpc" "main" {
  cidr_block                       = "10.10.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false

  tags = {
    name = "main"
  }

}

# Configuring Elastic IP Address
resource "aws_eip" "proxy-eip" {
  instance = aws_instance.proxyserver.id
}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.10.0/24"
  availability_zone       = var.availability_zone_public
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-subnet01"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.20.0/24"
  availability_zone = var.availability_zone_private
  tags = {
    Name = "private-subnet01"
  }
}



resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "vpc-gateway"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "gatewayroute"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route.id
}


resource "aws_security_group" "allow_ssh_in" {
  name        = "allow-ssh-in-sg"
  description = "Allow http ssh traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



resource "aws_security_group" "allow_proxy_in" {
  name        = "allow-proxy-in-sg"
  description = "allow proxy client to connect"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



resource "aws_instance" "proxyserver" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_in.id, aws_security_group.allow_proxy_in.id]
  key_name               = var.key_name
  /* Use your own key name */
  source_dest_check = false
  user_data         = <<-EOF
    #! /bin/bash
    yum update -y
    yum upgrade -y
    yum install squid.x86_64 -y
    sleep 20
    cp /etc/squid/squid.conf squid.conf_backup_$(date +"%Y_%m_%d_%s")
    sed -i  '4s/^/forwarded_for off\'$'\n/' /etc/squid/squid.conf
    sleep 5
    systemctl start squid
    systemctl enable squid
    sed -i  '5s/^/acl newnet src all\'$'\n/' /etc/squid/squid.conf
    sed -i  '34s/^/http_access allow newnet\'$'\n/' /etc/squid/squid.conf
    sed -i  '35s/^/cache_mgr WebMaster\'$'\n/' /etc/squid/squid.conf
    sed -i 's/3128/8080/g' /etc/squid/squid.conf
    sleep 10
    squid -k reconfigure
    systemctl restart squid
  EOF

  tags = {
    Name = "proxyserver"
  }

}



# Updating DNS Record to point at Elasic IP Address, if your domain is hosted outside aws route 53

resource "aws_route53_record" "www-record" {
  zone_id         = var.zone_id
  allow_overwrite = true
  name            = var.dns_name
  /* Use your own domain, if its registered on aws route 53 */
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.proxy-eip.public_ip}"]
}

# Write output up on execution, providing Elastic IP Address
output "Proxyserver-public-ip" {
  value = aws_eip.proxy-eip.public_ip
}




