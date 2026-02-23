# resource "kubectl_manifest" "karpenter_node_class" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.k8s.aws/v1beta1
#     kind: EC2NodeClass
#     metadata:
#       name: default
#     spec:
#       amiFamily: AL2023
#       role: ${module.karpenter.node_iam_role_name}
#       subnetSelectorTerms:
#         - tags:
#             kubernetes.io/role/internal-elb: "1" # Assuming your private subnets have this tag
#       securityGroupSelectorTerms:
#         - tags:
#             kubernetes.io/cluster/${module.eks.cluster_name}: "owned"
#   YAML

#   depends_on = [helm_release.karpenter]
# }

# resource "kubectl_manifest" "karpenter_node_pool" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.sh/v1beta1
#     kind: NodePool
#     metadata:
#       name: default
#     spec:
#       template:
#         spec:
#           nodeClassRef:
#             name: default
#           requirements:
#             - key: kubernetes.io/arch
#               operator: In
#               values: ["amd64"]
#             - key: karpenter.sh/capacity-type
#               operator: In
#               values: ["on-demand", "spot"]
#             - key: "karpenter.k8s.aws/instance-category"
#               operator: In
#               values: ["t", "m"]
#       disruption:
#         consolidationPolicy: WhenUnderutilized
#         expireAfter: 720h
#   YAML

#   depends_on = [kubectl_manifest.karpenter_node_class]
# }
