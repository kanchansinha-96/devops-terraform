###############################################################################
# Cluster
################################################################################

resource "aws_eks_cluster" "this" {

  name                      = "devops-aws"
  role_arn                  = aws_iam_role.eks-aws-role.arn
  version                   = "1.26"

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = ["subnet-0af9a9a3639e89275","subnet-08cba8f9c128f98de","subnet-0bd73e436bd785436"]
    endpoint_private_access = true
    endpoint_public_access  = false
  }
}
################################################################################

resource "aws_security_group" "cluster" {
  name        = "aws_eks_sg"
  description = "security created from terraform"
  vpc_id      = "vpc-02f551fc9f5caae54"



}

##########################role creation############################
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-aws-role" {
  name               = "eks-cluster-aws-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks-aws-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-aws-role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks-aws-role-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-aws-role.name
}

#####################################################################################

resource "aws_security_group_rule" "ingress_rules" {

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = [
      "172.31.0.0/16"
    ]
  description       = "Ingress from another computed security group"
  security_group_id = aws_security_group.cluster.id
  #source_security_group_id = try(var.ingress_rules[count.index].source_node_security_group, false) ? var.node_security_group_id : lookup(var.ingress_rules[count.index], "source_security_group_id", null)
}

resource "aws_security_group_rule" "ingress_rules_sg" {

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  description       = "Ingress from another computed security group"
  security_group_id = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group_rule" "egress_rules" {

  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = [
      "172.31.0.0/16"
    ]
  description       = "egress from another computed security group"
  security_group_id = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.cluster.id

}