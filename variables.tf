variable "cluster_name" {
  default = "trueprofile-eks-dev"
}
variable "aws_region" {
  default = "ap-southeast-1"
}

variable "kubernetes_version" {
  default     = 1.34
  description = "kubernetes version"
}

variable "project_name" {
  default = "trueprofile-eks"
}

variable "environment" {
  default = "dev"
}

variable "vpc_id" {
  default = "vpc-01a52a0935e6d11c5"
}

variable "private_subnet_ids" { #private_subnet_ids
  default = ["subnet-0f05fe169defa86a6", "subnet-018835eb17c58992f", "subnet-01a2d790325eb879d"]
}

variable "public_subnets_ids" {
  default = ["subnet-0934da8402084722e", "subnet-0c4494a4a45840229", "subnet-0188f45082b3bcecb"]
}