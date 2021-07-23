## Guide for run LB

### For Application Load Balancer
$ terraform plan --var "load_balancer_type=alb"
### If the plan is correct to what you expect :
$ terraform apply --var "load_balancer_type=alb"

### For Network Load Balancer
$ terraform plan --var "load_balancer_type=nlb"
### If the plan is correct to what you expect :
$ terraform apply --var "load_balancer_type=nlb"
