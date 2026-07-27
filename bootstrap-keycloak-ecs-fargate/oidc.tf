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
