resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rt"
  }
}

resource "aws_route_table_association" "rt-public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "sg"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22 # The starting port range allowed in the ec2 instance
  to_port           = 22 # The ending port range allowed in the ec2 insatnce
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_instance" "first_ec2_instance" {
  ami           = "ami-01eb696891a3b3bcf" # us-west-3
  instance_type = "t2.micro"
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true


    tags = {
    Name = "first_ec2_instance"
  }

}

