variable "awsVpcId" {
  type = string
}

variable "awsSgName" {
  type    = string
  default = ""
}

variable "awsInstanceId" {
  type    = string
  default = ""
}

resource "aws_security_group" "access-sg-vra" {
  name        = var.awsSgName
  description = "Security Group automatically created by vRA Cloud"
  vpc_id      = var.awsVpcId

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["10.0.0.0/8","132.189.0.0/16","172.16.0.0/12"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_instance" "instance" {
  instance_id = var.awsInstanceId
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.access-sg-vra.id
  network_interface_id = data.aws_instance.instance.network_interface_id
  depends_on           = [aws_security_group.access-sg-vra]
}
