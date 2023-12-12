module "this" {
  source                 = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.17.2"
  create                 = true
  create_sg              = true
  use_name_prefix        = false
  name                   = "terraform-eks-sg"
  description            = "Security groroup creation from IG"
  vpc_id                 = "vpc-0cff6df3d7e9f59d8"
  revoke_rules_on_delete = false
  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "Port"
      source_security_group_id = "sg-015927094f46d7d2c"
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "allow pods to communicate"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "self"
      self        = true
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "allow all traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}