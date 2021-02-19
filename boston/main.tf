variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-04f5641b0d178a27a"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}
