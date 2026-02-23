# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# resource "aws_iam_role" "trueprofile" {
#   name               = "eks-pod-identity-trueprofile-dev"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }
# # Not using S3 as of now, will implement it soon
# # resource "aws_iam_role_policy_attachment" "example_s3" {
# #   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# #   role       = aws_iam_role.example.name
# # }

#  resource "aws_iam_role_policy_attachment" "karpenter" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonkarpenterReadOnlyAccess"
# #   role       = aws_iam_role.trueprofile.name
#     role = module.eks.eks_managed_node_groups.node_iam_role_arn

# }

# resource "aws_eks_pod_identity_association" "karpenter" {
#   cluster_name    = aws_eks_cluster.trueprofile.name
#   namespace       = "dev"
#   service_account = "karpenter"
#   role_arn        = module.eks.eks_managed_node_groups.node_iam_role_arn
# }

# # List of mandatory policies for worker nodes
# # Attach policies to ALL managed node groups in your module
# locals {
#   node_policies = [
#     "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
#     "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   ]
# }

# resource "aws_iam_role_policy_attachment" "node_group_mandatory_policies" {
#   for_each = {
#     # setproduct creates a list of [group_key, policy_arn]
#     for pair in setproduct(keys(module.eks.eks_managed_node_groups), local.node_policies) :
#     "${pair[0]}-${basename(pair[1])}" => {
#       role_name  = module.eks.eks_managed_node_groups[pair[0]].iam_role_name
#       policy_arn = pair[1]
#     }
#   }

#   policy_arn = each.value.policy_arn
#   role       = each.value.role_name
# }


# 1. Pod Identity Trust Policy (Correct)
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

# 2. General Application Role (e.g., for your trueprofile app)
resource "aws_iam_role" "trueprofile_app" {
  name               = "eks-pod-identity-trueprofile-dev"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# 3. Pod Identity Association for your Application
resource "aws_eks_pod_identity_association" "trueprofile_app" {
  cluster_name    = module.eks.cluster_name
  namespace       = "dev"
  service_account = "trueprofile-sa"
  role_arn        = aws_iam_role.trueprofile_app.arn
}

# # 4. Karpenter Controller Permissions
# # Instead of manual attachments, use the Karpenter module's built-in IAM features
# # This provides the necessary permissions to launch/terminate EC2 instances.
# resource "aws_iam_role_policy_attachment" "karpenter_controller_additional" {
#   # This provides necessary permissions for Karpenter to function
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   role       = module.karpenter.iam_role_name 
# }

# # 5. Pod Identity Association for Karpenter Controller
# resource "aws_eks_pod_identity_association" "karpenter" {
#   cluster_name    = module.eks.cluster_name
#   namespace       = "karpenter" # Karpenter is usually in its own namespace
#   service_account = "karpenter"
#   role_arn        = module.karpenter.iam_role_arn
# }

/* 
  NOTE: You do NOT need the 'node_group_mandatory_policies' loop. 
  The EKS module (v21.0) attaches these automatically to every 
  managed node group defined in your module block.
*/
