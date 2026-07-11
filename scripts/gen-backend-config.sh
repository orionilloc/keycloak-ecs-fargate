#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="${ROOT_DIR}/backend.hcl"

command -v aws &> /dev/null || { echo "aws CLI not found." >&2; exit 1; }

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null) \
  || { echo "Failed to resolve AWS account ID." >&2; exit 1; }
[[ -n "${ACCOUNT_ID}" ]] || { echo "Empty account ID returned." >&2; exit 1; }

if [[ -f "${OUTPUT_FILE}" ]]; then
  read -rp "backend.hcl already exists. Overwrite? [y/N] " confirm
  [[ "${confirm}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

cat > "${OUTPUT_FILE}" <<EOF
bucket = "keycloak-ecs-fargate-terraform-state-${ACCOUNT_ID}"
region = "us-east-1"
key    = "keycloak-ecs-fargate/terraform.tfstate"
EOF

echo "backend.hcl generated at ${OUTPUT_FILE} for account ${ACCOUNT_ID}"
