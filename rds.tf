#rds.tf

resource "aws_db_subnet_group" "keycloak_db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = { Name = "${var.project_name}-DBSubnetGroup" }
}

resource "aws_db_instance" "keycloak_db" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "keycloak"
  username = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]

  db_subnet_group_name   = aws_db_subnet_group.keycloak_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_rds.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true

  tags = { Name = "${var.project_name}-DB" }
}
