# oidc.tf

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "gha_role" {
  name = "${var.project_name}-gha-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:orionilloc/keycloak-ecs-fargate:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "gha_plan_readonly" {
  name = "${var.project_name}-gha-plan-readonly"
  role = aws_iam_role.gha_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "rds:Describe*",
          "rds:ListTagsForResource",
          "ecs:Describe*",
          "ecs:List*",
          "elasticloadbalancing:Describe*",
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate",
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:GetResourcePolicy",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "sts:GetCallerIdentity",
          "access-analyzer:ValidatePolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "gha_backend_access" {
  name = "${var.project_name}-gha-backend-access"
  role = aws_iam_role.gha_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_prefix}-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::${var.bucket_prefix}-${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}
