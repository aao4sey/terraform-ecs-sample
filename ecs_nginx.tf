resource "aws_ecs_task_definition" "nginx" {
  family                = "nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "512"
  memory = "1024"
  execution_role_arn = "${aws_iam_role.task_role.arn}"
  depends_on = [
	"aws_iam_role.task_role",
	"aws_cloudwatch_log_group.nginx",
    "aws_lb_target_group.target",
    "aws_lb_listener.listener_80",
    "aws_lb.alb"
  ]
  container_definitions = <<DEFINITION
[
  {
       "name": "nginx",
       "image": "nginx:latest",
       "memoryReservation": 1024,
       "cpu": 512,
       "essential": true,
       "portMappings": [
           {
               "containerPort": 80,
               "protocol": "tcp"
           }
       ],
       "environment": null,
       "mountPoints": null,
       "volumesFrom": null,
       "hostname": null,
       "user": null,
       "workingDirectory": null,
       "extraHosts": null,
       "logConfiguration": {
           "logDriver": "awslogs",
           "options": {
               "awslogs-group": "/ecs/nginx",
               "awslogs-region": "us-east-1",
               "awslogs-stream-prefix": "ecs"
           }
       },
       "ulimits": null,
       "dockerLabels": null
   }
]
DEFINITION
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn       = "${aws_lb_target_group.target.arn}"
    container_name = "nginx"
    container_port = 80
  }

  network_configuration {
    subnets = ["${aws_subnet.app_subnet.*.id}"]
    security_groups = [
      "${aws_default_security_group.default.id}"
    ]
  }
}
