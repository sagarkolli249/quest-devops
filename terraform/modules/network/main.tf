resource "aws_lb" "load_balancer" {
  name               = var.load_balancer_name
  internal           = !var.is_internet_facing
  security_groups    = var.security_groups
  subnets            = var.subnets
  arn                = var.alb_certificate_arn
  load_balancer_type = var.load_balancer_type
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type = var.default_action_type
    fixed_response {
      content_type = var.response_content_type
      message_body = var.response_message
      status_code  = var.response_status_code
    }
  }
}
