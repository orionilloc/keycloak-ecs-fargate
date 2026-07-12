#security.tf

resource "aws_security_group" "sg_alb" {
  vpc_id      = aws_vpc.lab_vpc.id
  name        = "${var.project_name}-alb-sg"
  description = "Allow public https ingress to ALB"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ecs_task.id]
  }

  tags = { Name = "${var.project_name}-ALBSG" }
}

resource "aws_security_group" "sg_ecs_task" {
  vpc_id      = aws_vpc.lab_vpc.id
  name        = "${var.project_name}-ecs-task-sg"
  description = "Keycloak task; allow inbound from ALB only, outbound to RDS + external IdPs"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-ECSTaskSG" }
}

resource "aws_security_group" "sg_rds" {
  vpc_id      = aws_vpc.lab_vpc.id
  name        = "${var.project_name}-rds-sg"
  description = "Postgres — inbound from ECS task only, no egress needed"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ecs_task.id]
  }

  tags = { Name = "${var.project_name}-RDSSG" }
}
