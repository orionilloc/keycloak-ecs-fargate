#secrets.tf

resource "random_password" "db_password" {
  length  = 20
  upper   = true
  lower   = true
  numeric = true
  special = true
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}/db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "keycloak_db_user"
    password = random_password.db_password.result
  })
}

resource "random_password" "kc_admin_password" {
  length  = 20
  upper   = true
  lower   = true
  numeric = true
  special = true
}

resource "aws_secretsmanager_secret" "kc_admin_credentials" {
  name = "${var.project_name}/admin-credentials"
}

resource "aws_secretsmanager_secret_version" "kc_admin_credentials" {
  secret_id = aws_secretsmanager_secret.kc_admin_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.kc_admin_password.result
  })
}
