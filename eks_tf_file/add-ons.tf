data "aws_eks_cluster" "eksaddon" {
  name = "devops-aws"
}
################################################################################
# EKS managed Addons
################################################################################
resource "aws_eks_addon" "cni" {

  cluster_name                = "devops-aws"
  addon_name                  = "vpc-cni"
  addon_version               = "v1.15.3-eksbuild.1"

}

resource "aws_eks_addon" "kubeproxy" {

  cluster_name                = "devops-aws"
  addon_name                  = "kube-proxy"
  addon_version               = "v1.26.9-eksbuild.2"


}

resource "aws_eks_addon" "coredns" {

  cluster_name                = "devops-aws"
  addon_name                  = "coredns"
  addon_version               = "v1.9.3-eksbuild.10"


}
