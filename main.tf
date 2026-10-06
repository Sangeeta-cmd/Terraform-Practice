provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "key" {
  key_name   = "terraform-demo-key"
  public_key = file("C:/Users/Sangeeta/.ssh/id_ed25519.pub")
}

variable "cidr" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "demo-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "rtassociate" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "mysg" {
  name   = "my-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "Allow Http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allowAllOutboundTraffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "demo" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet1.id
  key_name               = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.mysg.id]

  # Connection block describing how the provisioner connects to the given instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("C:/Users/Sangeeta/.ssh/id_ed25519")
    host        = self.public_ip
  }

  # Provisioner to model specific actions on the local machine or on a remote machine in order to prepare servers or other infrastructure objects for service
  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "app.py"
    destination = "/home/ubuntu/app.py"
  }

  #Invokes a script on a remote resource after it is created.
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from Remote Instance' ",
      "sudo apt update -y", 
      "sudo apt install python3-pip python3.14-venv -y",
      "cd /home/ubuntu",
      "python3 -m venv . && ls",      # Creating Virtual Env for python to install its packages bcz in Debian Ubuntu OS, this is considered as external pckg, so created venv.
      "pip3 install flask",  #You need elevated privileges when binding a normal application to a privileged port (below 1024 (1 to 1024)). Means u need to run the app as root if its port is 80/under the 1024. SO give 5000 as port and allow it in security group
      "python3 app.py &"     # Running App in background
    ]
  }

}

