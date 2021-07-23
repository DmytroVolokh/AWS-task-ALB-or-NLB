variable "vpc_id" {
  type    = string
  default = "vpc-07e4b9611441050fa"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_a" {
  type    = string
  default = "subnet-0828d3e44d0057a5b"
}

variable "subnet_b" {
  type    = string
  default = "subnet-016681396c78887e9"
}

variable "subnet_c" {
  type    = string
  default = "subnet-0011bdd5c40923dc4"
}

variable "load_balancer_type" {
  type    = string
  default = "alb"
}

variable "list_instances" {
  type    = set(string)
  default = ["i-0eb64a3d0b4e009cd", "i-09bbbc27bcbdd4350", "i-09c9360658e08e67f"]
}
