data "aws_caller_identity" "current" {

}

data "aws_iam_openid_connect_provider" "eks_cluster_netflix" {
  arn = module.iam.oidc_provider_arn
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.eks_cluster_netflix_name
}

