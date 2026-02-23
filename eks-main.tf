# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 21.0" # Best practice: use pessimistic constraint

#   name    = var.cluster_name
#   kubernetes_version = "1.35" # Specify your K8s version

#   vpc_id     = var.vpc_id
#   subnet_ids = var.private_subnet_ids

#   endpoint_public_access = true



#   # REQUIRED for v21.0 to ensure you have access to the cluster
#   enable_cluster_creator_admin_permissions = true

#   # Modern Add-ons managed within the module
#   addons = {
#     eks-pod-identity-agent = {
#       most_recent = true
#     }
#     vpc-cni = {
#       most_recent = true
#     }
#     kube-proxy = {
#         most_recent = true
#     }
#   }

#   eks_managed_node_groups = {
#     g1 = {
#       name           = "private-group-0" # Changed from node_group_name to name
#       instance_types = ["t3.medium"]
#       min_size       = 1
#       max_size       = 4
#       desired_size   = 1

#       # Fixed: Use 'taints' (plural) for v21.0
#       taint = [{
#         key    = "dedicated"
#         value  = "lowPriority"
#         effect = "NO_SCHEDULE"
#       }]
#     }

#     g2 = {
#       name           = "private-group-1"
#       instance_types = ["t3.medium"]
#       min_size       = 4
#       max_size       = 10
#       desired_size   = 4
#     }

#     g3 = {
#       name           = "private-group-staging"
#       instance_types = ["t3.medium"]
#       min_size       = 2
#       max_size       = 10
#       desired_size   = 6
#       labels = {
#         "environment" = "staging"
#       }
#     }

#     g4 = {
#       name           = "private-group-sentry"
#       instance_types = ["t3.medium"]
#       min_size       = 1
#       max_size       = 2
#       desired_size   = 1
#       labels = {
#         "environment" = "sentry"
#       }
#       taint = [{
#         key    = "environment"
#         value  = "sentry"
#         effect = "NO_SCHEDULE"
#       }]
#     }
#   }

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }

# module "karpenter" {
#   source  = "terraform-aws-modules/eks/aws//modules/karpenter"
#   version = "~> 21.0"

#   cluster_name = module.eks.cluster_name

#   # Enable Karpenter to create its own IAM role for the nodes it provisions
#   create_node_iam_role = true

#   # Allow the module to create the EKS Access Entry for Karpenter nodes automatically
#   create_access_entry = true

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.31" # Note: EKS 1.35 is not yet released; 1.31 is current latest

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  # Add-ons: Removed pod-identity-agent (unsupported on Fargate)
  addons = {
    vpc-cni    = { most_recent = true }
    kube-proxy = { most_recent = true }
    # coredns    = { most_recent = true } # CoreDNS is vital for Fargate
  }

  # Fargate Profiles replace Node Groups
  fargate_profiles = {
    # This profile ensures standard apps run on Fargate
    default = {
      name = "default"
      selectors = [
        { namespace = "default" },
        { namespace = "kube-system" } # Required to run CoreDNS on Fargate
      ]
    }

    # Example for your 'sentry' environment
    sentry = {
      name = "sentry"
      selectors = [
        {
          namespace = "sentry"
          labels    = { environment = "sentry" }
        }
      ]
    }
    # Example for your 'staging' environment
    staging = {
      name = "staging"
      selectors = [
        {
          namespace = "staging"
          labels    = { environment = "staging" }
        }
      ]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


