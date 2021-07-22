#------------------Data_Sources-------------------------

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_subnet_ids" "subnet_public" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = ["AWS-task-PublicSubnet-a", "AWS-task-PublicSubnet-b", "AWS-task-PublicSubnet-c"]
  }
}

# data "aws_instance" "web" {
#   filter {
#     name   = "image-id"
#     values = [data.aws_ami.latest_amazon_linux.id]
#   }
# }
