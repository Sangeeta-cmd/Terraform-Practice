variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "tb" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "my_rt"
  }
}

resource "aws_route_table_association" "rta1" {
  route_table_id = aws_route_table.tb.id
  subnet_id      = aws_subnet.sub1.id
}

resource "aws_route_table_association" "rta2" {
  route_table_id = aws_route_table.tb.id
  subnet_id      = aws_subnet.sub2.id
}

resource "aws_security_group" "mysg" {
  name   = "my-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = "Allow HTTP in VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH in VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "AllowAllOutboudTraffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#To see user-data inside the instance cat /var/lib/cloud/instances/*/user-data.txt
# To see output of user-data --> cat /var/log/cloud-init-output.log
# By default - user-data run as root user. And it only run the script at the time of launch. If u want to make it run every reboot thn we need to 
# add MIME module ---> in script

resource "aws_instance" "web-server1" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata1.sh"))               
  tags = {
    Name = "webserver1"
  }
}

resource "aws_instance" "web-server2" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata2.sh"))
  tags = {
    Name = "webserver2"
  }
}

resource "aws_lb" "mylb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "mytg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web-server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web-server2.id
  port             = 80
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


output "lb_dns" {
  value = aws_lb.mylb.dns_name
}