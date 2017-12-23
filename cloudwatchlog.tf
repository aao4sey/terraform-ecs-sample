resource "aws_cloudwatch_log_group" "nginx" {
    name = "/ecs/nginx"
    retention_in_days = 7
}
