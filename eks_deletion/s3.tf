terraform {
  backend "s3" {
    bucket  = "eks-netflix-argocd"
    key     = "eks-alb"
    region  = "us-east-1"
    encrypt = true
    profile = "default"
  }
}
