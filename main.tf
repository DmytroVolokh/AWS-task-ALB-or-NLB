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
    protocol    = "TCP"
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

resource "aws_lb" "alb" {
  name               = "terraform-alb"
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = [var.subnet_a, var.subnet_b, var.subnet_c]
  count              = var.load_balancer_type == "alb" ? 1 : 0
  tags = {
    Name = "terraform-alb"
  }
}

#------------------Network_Load_Balancer-----------------------
resource "aws_lb" "nlb" {
  name               = "terraform-nlb"
  load_balancer_type = "network"
  subnets            = [var.subnet_a, var.subnet_b, var.subnet_c]
  count              = var.load_balancer_type == "nlb" ? 1 : 0
  tags = {
    Name = "terraform-nlb"
  }
}
#------------------Listener_for_ALB---------------------

# resource "aws_alb_listener" "listener_http" {
#   load_balancer_arn = aws_lb.alb[0].arn
#   port              = "80"
#   protocol          = "HTTP"
#
#   default_action {
#     target_group_arn = aws_alb_target_group.web.arn
#     type             = "forward"
#   }
# }

#------------------Listener_for_NLB---------------------
resource "aws_lb_listener" "listener_tcp" {
  load_balancer_arn = aws_lb.nlb[0].arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.web.arn
    type             = "forward"
  }
}
#--------------------Target_Group_attachment-----------------------
# resource "aws_lb_target_group_attachment" "web" {
#   for_each         = var.list_instances
#   target_group_arn = aws_alb_target_group.web.arn
#   target_id        = each.key
#   port             = 80
# }
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = "i-0eb64a3d0b4e009cd"
  port             = 80
}
resource "aws_lb_target_group_attachment" "web-1" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = "i-09bbbc27bcbdd4350"
  port             = 80
}
resource "aws_lb_target_group_attachment" "web-2" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = "i-09c9360658e08e67f"
  port             = 80
}

#-------------------------Target_Group_ALB---------------------------

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

#-------------------------Target_Group_NLB---------------------------

resource "aws_lb_target_group" "web" {
  name     = "terraform-nlb-target"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
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
