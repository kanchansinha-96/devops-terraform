data "aws_eks_cluster" "eks" {
  name = "devops-aws"
}
resource "aws_launch_template" "lt" {
  name = "eks_lt"
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }
  vpc_security_group_ids = [module.this.security_group_id]

}
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.eks.version}/amazon-linux-2/recommended/release_version"
}
module "eks_managed_node_group" {
  source                            = "github.com/terraform-aws-modules/terraform-aws-eks.git//modules/eks-managed-node-group?ref=v19.12.0"
  name                              = "complete-eks-mng"
  use_name_prefix                   = false
  cluster_name                      = "devops-aws"
  cluster_version                   = "1.26"
  subnet_ids                        = ["subnet-0a8aedbc76a97ec1b", "subnet-08eae6c9eecaf9d68", "subnet-0f07b1cfdae48c26d"]
  create_launch_template            = true
  use_custom_launch_template        = false
  launch_template_id                = "eks_lt"
  create_iam_role                   = true
  iam_role_arn                      = "aws_iam_role.eks-aws-node-role.arn"
  cluster_primary_security_group_id = data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  ami_type                          = "AL2_x86_64"
  ami_release_version               = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  min_size                          = 2
  max_size                          = 6
  desired_size                      = 2
  instance_types                    = ["m5.4xlarge"]
  capacity_type                     = "ON_DEMAND"
  update_config = {
    max_unavailable = 1
  }
  depends_on = [aws_launch_template.lt]

}

data "aws_iam_policy_document" "assume_role_node" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-aws-node-role" {
  name               = "eks-node-aws-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks-aws-role-AmazonEKSClusterPolicy-node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-aws-node-role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
#resource "aws_iam_role_policy_attachment" "eks-aws-role-AmazonEBSCSIDriverPolicy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy"
#  role       = aws_iam_role.eks-aws-node-role.name
#}

resource "aws_iam_role_policy_attachment" "eks-aws-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-aws-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-aws-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-aws-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-aws-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-aws-node-role.name
}