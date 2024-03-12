# Datasource: AWS Load Balancer Controller IAM Policy get from aws-load-balancer-controller/ GIT Repo (latest)
data "http" "lbc_iam_policy" {
  url = var.data_http_lbc_iam_policy_url # "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = var.data_http_lbc_iam_policy_request_headers_accept # "application/json"
  }
}

data "aws_lb" "eks" {
  depends_on = [aws_lb.eks]
  name       = aws_lb.eks.name
}

# data "aws_security_groups" "filtered" {
#   tags = {
#     "elbv2.k8s.aws/cluster"    = "eks-netflix-cluster"
#     "ingress.k8s.aws/stack"     = "argocd/argocd-server"
#     "ingress.k8s.aws/resource"  = "ManagedLBSecurityGroup"
#   }
# }

# data "aws_security_groups" "filtered_shared" {
#   tags = {
#     "elbv2.k8s.aws/resource" = "backend-sg"
#     "elbv2.k8s.aws/cluster"  = "eks-netflix-cluster"
#   }
# }

data "aws_instance" "eks_netflix" { 
  filter {
    name   = "tag:eks:cluster-name"
    values = ["eks-netflix-cluster"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }


}

data "aws_instance" "bastion" { 
  filter {
    name   = "tag:Name"
    values = ["bastion-host"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}