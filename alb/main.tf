variable "name" {
  description = "ALB name, e.g cdn"
}

variable "is_internal" {
  description = "If true, the ALB will be internal"
  default = true
}

variable "target_group_name" {
  description = "target group name"
}

variable "subnet_ids" {
  description = "Comma separated list of subnet IDs"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "port" {
  description = "Instance port"
}

variable "security_groups" {
  description = "Comma separated list of security group IDs"
}

variable "protocol" {
  description = "Protocol to use, HTTP or TCP"
}

variable "log_bucket" {
  description = "S3 bucket name to write ALB logs into"
}

variable "log_prefix" {
  description = "ALB logs prefix"
}

resource "aws_alb" "main" {
  name            = "${var.name}"
  internal        = "${var.is_internal}"
  subnets         = ["${split(",", var.subnet_ids)}"]
  security_groups = ["${split(",",var.security_groups)}"]

  access_logs {
    bucket = "${var.log_bucket}"
    prefix = "${var.log_prefix}"
  }

  tags {
    Name        = "${var.name}-application-balancer"
    Service     = "${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "main" {
  name     = "lifei-alb-tg"
  port     = "${var.port}"
  protocol = "${var.protocol}"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port     = "${var.port}"
  protocol = "${var.protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.main.arn}"
    type = "forward"
  }
}

/**
 * Outputs.
 */

// The ALB name.

output "id" {
  value = "${aws_alb.main.id}"
}

output "arn" {
  value = "${aws_alb.main.arn}"
}

output "dns_name" {
  value = "${aws_alb.main.dns_name}"
}

output "zone_id" {
  value = "${aws_alb.main.zone_id}"
}

output "canonical_hosted_zone_id" {
  value = "${aws_alb.main.canonical_hosted_zone_id}"
}
