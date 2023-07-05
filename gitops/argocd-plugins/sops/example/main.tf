#region AWS KMS CMK for Helm-Secrets encryption
resource "aws_kms_key" "helm_secrets_dev" {
  description             = "GitHub Secrets Encryption Key for DEV env"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "helm_secrets_dev" {
  name          = "alias/helm-secret/dev"
  target_key_id = aws_kms_key.helm_secrets_dev.key_id
}

resource "aws_kms_key" "helm_secrets_stg" {
  description             = "GitHub Secrets Encryption Key for STG env"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "helm_secrets_stg" {
  name          = "alias/helm-secret/stg"
  target_key_id = aws_kms_key.helm_secrets_stg.key_id
}

# output arn
output "kms_dev_arn" {
  value = aws_kms_key.helm_secrets_dev.arn
}

output "kms_stg_arn" {
  value = aws_kms_key.helm_secrets_stg.arn
}
#endregion

#region role for ArgoCD to access KMS key
# module "argocd_repo_server_iam_role" {
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version                       = "5.10.0"
#   create_role                   = true
#   role_name                     = "EKS-argocd-repo-server-${var.eks_cluster_name}"
#   provider_url                  = trimprefix(module.eks.cluster_oidc_issuer_url, "https://")
#   role_policy_arns              = [aws_iam_policy.argocd_server_iam_policy.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:argocd:argocd-repo-server"]
#   tags = {
#     Terraform = "true"
#   }
# }

# resource "aws_iam_policy" "argocd_server_iam_policy" {
#   name        = "EKS-argocd-server-${var.eks_cluster_name}"
#   description = "EKS ArgoCD server policy for cluster ${var.eks_cluster_name}"
#   policy      = data.aws_iam_policy_document.argocd_repo_server_kms_iam_policy.json
# }

# data "aws_iam_policy_document" "argocd_repo_server_kms_iam_policy" {
#   statement {
#     sid       = "ArgoCDKMS"
#     effect    = "Allow"
#     resources = [
#       aws_kms_key.helm_secrets_dev.arn,
#       aws_kms_key.helm_secrets_stg.arn,
#       aws_kms_key.helm_secrets_prd.arn,
#       ]

#     actions = [
#       "kms:Decrypt*",
#       "kms:Encrypt*",
#       "kms:GenerateDataKey",
#       "kms:ReEncrypt*",
#       "kms:DescribeKey",
#     ]
#   }
# }
#endregion

