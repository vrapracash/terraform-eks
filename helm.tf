# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#       command     = "aws"
#     }
#   }
# }

# Not using karpenter for now, but this is the basic Helm release block for it. You can customize the values as needed.
# resource "helm_release" "karpenter" {
#   namespace        = "karpenter"
#   create_namespace = true
#   name             = "karpenter"
#   repository       = "oci://public.ecr.aws/karpenter"
#   chart            = "karpenter"
#   version          = "1.0.0" 

#   # Updated for Karpenter v1.0.0 schema
#   set {
#     name  = "settings.clusterName"
#     value = module.eks.cluster_name
#   }

#   set {
#     name  = "settings.interruptionQueue"
#     value = module.karpenter.queue_name
#   }

#   # IMPORTANT: In v1.0.0, the serviceAccount name is usually 'karpenter'
#   set {
#     name  = "serviceAccount.name"
#     value = "karpenter"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.karpenter.iam_role_arn
#   }

#   # Ensure the Pod Identity Agent is running first if using Pod Identity
#   # Otherwise, Helm will install, but the Pod will fail to get its role
#   depends_on = [module.eks.cluster_addons] 
# }
