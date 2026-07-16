#ecs.tf

resource "aws_ecs_cluster" "keycloak" {
  name = "${var.project_name}-cluster"

  tags = { Name = "${var.project_name}-ECSCluster" }
}

resource "aws_cloudwatch_log_group" "keycloak" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "keycloak" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "keycloak"
      image     = "quay.io/keycloak/keycloak:26.6.4"
      essential = true
      command   = ["start"]

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        },
        {
          containerPort = 9000
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "KC_DB_URL_HOST", value = aws_db_instance.keycloak_db.address },
        { name = "KC_DB_URL_DATABASE", value = "keycloak" },
        { name = "KC_HOSTNAME", value = "auth.${var.domain_name},
        { name = "KC_HTTP_ENABLED", value = "true" },
        { name = "KC_PROXY", value = "edge" },
        { name = "KC_HEALTH_ENABLED", value = "true" }
      ]

      secrets = [
        {
          name      = "KC_DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:username::"
        },
        {
          name      = "KC_DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:password::"
        },
        {
          name      = "KEYCLOAK_ADMIN"
          valueFrom = "${aws_secretsmanager_secret.kc_admin_credentials.arn}:username::"
        },
        {
          name      = "KEYCLOAK_ADMIN_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.kc_admin_credentials.arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.keycloak.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "keycloak"
        }
      }
    }
  ])

  tags = { Name = "${var.project_name}-TaskDef" }
}

resource "aws_ecs_service" "keycloak" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.keycloak.id
  task_definition = aws_ecs_task_definition.keycloak.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    security_groups  = [aws_security_group.sg_ecs_task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.keycloak.arn
    container_name   = "keycloak"
    container_port   = 8080
  }

  health_check_grace_period_seconds = 120

  depends_on = [aws_lb_listener.https]

  tags = { Name = "${var.project_name}-ECSService" }
}
