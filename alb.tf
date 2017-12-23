
resource "aws_lb" "alb" {
    name = "fargate-test"
    load_balancer_type = "application"
    security_groups = ["${aws_default_security_group.default.id}","${aws_security_group.http.id}"]
    subnets = ["${aws_subnet.front_subnet.*.id}"]
}

resource "aws_lb_target_group" "target" {
    name = "target"
    port = 80
    protocol = "HTTP"
    vpc_id = "${aws_vpc.vpc.id}"
    target_type = "ip"
    deregistration_delay = 300
    health_check {
        healthy_threshold = 2
        interval = 11
        port = "80"
        protocol = "HTTP"
        path = "/"
        timeout = 10
        unhealthy_threshold = 2
        matcher = "200"
    }
}

resource "aws_lb_listener" "listener_80" {
    port = "80"
    protocol = "HTTP"
    load_balancer_arn = "${aws_lb.alb.arn}"
    default_action {
        target_group_arn = "${aws_lb_target_group.target.arn}"
        type = "forward"
    }
    depends_on = ["aws_lb.alb","aws_lb_target_group.target"]
}
