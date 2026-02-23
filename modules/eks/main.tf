module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_irsa = true

  # Disable default node groups
  eks_managed_node_groups = {}

  # Enable Fargate
  fargate_profiles = {
    default = {
      name = "default"

      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]

      subnet_ids = var.private_subnet_ids

      tags = {
        Environment = var.environment
      }
    }

    apps = {
      name = "apps"

      selectors = [
        {
          namespace = "apps"
        }
      ]

      subnet_ids = var.private_subnet_ids
    }
  }

  tags = var.tags
}