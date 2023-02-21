provider "aws" {
  region = "ap-south-1"
}

variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
#variable ssh_key_private {}


resource "aws_vpc" "myapp-vpc" {
    enable_dns_hostnames = true
    cidr_block = var.vpc_cidr_blocks
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id =  aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
   tags = {
    Name: "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami" {
  value       = data.aws_ami.latest-amazon-linux-image.id
}

output "aws_public_ip" {
  value       = aws_instance.myapp-server.public_ip
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id

  instance_type = var.instance_type
  associate_public_ip_address = true

  availability_zone = var.avail_zone
  key_name = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  subnet_id = aws_subnet.myapp-subnet-1.id

  #user_data = file("entry-script.sh")

   tags = {
    Name: "${var.env_prefix}-server"
  }
}

# resource "null_resource" "configure-server" {
#   triggers = {
#     trigger = aws_instance.myapp-server.public_ip
#   }
#   provisioner "local-exec" {
#     working_dir = "/home/zahran/ansible"
#     command = "ansible-playbook --inventory ${aws_instance.myapp-server.public_ip}, --private-key ${var.ssh_key_private} --user ec2-user deploy-docker-ec2-user.yaml"
#   }
#   }

resource "aws_instance" "myapp-server_2" {
  ami = data.aws_ami.latest-amazon-linux-image.id

  instance_type = var.instance_type
  associate_public_ip_address = true

  availability_zone = var.avail_zone
  key_name = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  subnet_id = aws_subnet.myapp-subnet-1.id

  #user_data = file("entry-script.sh")

   tags = {
    Name: "${var.env_prefix}-server_2"
  }
}
resource "aws_instance" "myapp-server_3" {
  ami = data.aws_ami.latest-amazon-linux-image.id

  instance_type = var.instance_type
  associate_public_ip_address = true

  availability_zone = var.avail_zone
  key_name = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  subnet_id = aws_subnet.myapp-subnet-1.id

  #user_data = file("entry-script.sh")

   tags = {
    Name: "${var.env_prefix}-server_3"
  }
}
