data "aws_eks_cluster" "eks" {
  name = "devops-aws"
}
resource "aws_launch_template" "lt" {
  name  = "eks_lt"
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  } 
  vpc_security_group_ids = []

}
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.eks.version}/amazon-linux-2/recommended/release_version"
}
module "eks_managed_node_group" {
  source                            = "github.com/terraform-aws-modules/terraform-aws-eks.git//modules/eks-managed-node-group?ref=v19.12.0"
  name                              = "complete-eks-mng"
  use_name_prefix                   = true
  cluster_name                      = "devops-aws"
  cluster_version                   = "1.26"
  subnet_ids                        = ["subnet-0af9a9a3639e89275","subnet-08cba8f9c128f98de","subnet-0bd73e436bd785436"]
  create_launch_template            = true
  use_custom_launch_template        = false
  launch_template_id                = aws_launch_template.lt.id
  create_iam_role                   = true
  iam_role_arn                      = ""
  cluster_primary_security_group_id = data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  ami_type                          = "AL2_x86_64"
  ami_release_version               = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  min_size                          = 2
  max_size                          = 6
  desired_size                      = 2
  instance_types                    = ["c3.xlarge"]
  capacity_type                     = "ON_DEMAND"
  update_config                     = {
    max_unavailable = 1
  }
  depends_on                        = [aws_launch_template.lt]

}