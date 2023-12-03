data "aws_eks_cluster" "eksaddon" {
  name = "devops-aws"
}
################################################################################
# EKS managed Addons
################################################################################
resource "aws_eks_addon" "cni" {

  cluster_name = "devops-aws"
  addon_name   = "vpc-cni"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = "v1.15.3-eksbuild.1"

}

resource "aws_eks_addon" "kubeproxy" {

  cluster_name = "devops-aws"
  addon_name   = "kube-proxy"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = "v1.26.9-minimal-eksbuild.2"


}

resource "aws_eks_addon" "coredns" {

  cluster_name = "devops-aws"
  addon_name   = "coredns"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = "v1.9.3-eksbuild.10"


}
