provider "aws" {
  region = "eu-west-2"
}

#------------------Security_Group-----------------------

resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-alb-security-group"
  }
}

#------------------Application_Load_Balancer-----------------------

resource "aws_alb" "alb" {
  name            = "terraform-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = [var.subnet_a, var.subnet_b, var.subnet_c]
  tags = {
    Name = "terraform-alb"
  }
}

#------------------Listener_for_ALB---------------------

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web.arn
    type             = "forward"
  }
}


#--------------------Target_Group_attachment-----------------------

resource "aws_alb_target_group_attachment" "web" {
  target_group_arn = aws_alb_target_group.web.arn
  target_id        = "i-043c8c4c58d2c0b4c"
  port             = 80
}

#-------------------------Target_Group---------------------------

resource "aws_alb_target_group" "web" {
  name     = "terraform-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    matcher             = "200"
  }
}

#------------------------Instances-------------------------

resource "aws_instance" "web" {
  for_each               = data.aws_subnet_ids.subnet_public.ids
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.alb.id]
  subnet_id              = each.value
  user_data              = file("user_data.sh")

  tags = {
    Name = "instance_count-${each.value}"
  }
}


# resource "aws_instance" "web" {
#   count = 3
#
#   ami           = data.aws_ami.latest_amazon_linux.id
#   instance_type = var.instance_type
#
#   tags = {
#     Name = "Server-Number-${count.index + 1}"
#   }
# }
