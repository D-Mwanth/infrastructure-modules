resource "aws_iam_role" "eks" {
  name = "${var.env}-env-eks-cluster-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# Attach iam policy to the iam role
resource "aws_iam_role_policy_attachment" "eks" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create eks cluster
resource "aws_eks_cluster" "this" {
  name     = "${var.env}-${var.eks_name}"
  version = var.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true
    subnet_ids =var.subnet_ids
  }
  depends_on = [aws_iam_role_policy_attachment.eks]
}

### Create iam role for nodes
resource "aws_iam_role" "nodes" {
  name = "${var.env}-${var.eks_name}-eks-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach policy to the nodes iam role
resource "aws_iam_role_policy_attachment" "nodes" {
    for_each = var.node_iam_policies

    policy_arn = each.value
    role = aws_iam_role.nodes.name
}

# Create eks node groups
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  # connect node  groups to the cluster
  cluster_name = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn = aws_iam_role.nodes.arn

  subnet_ids = var.subnet_ids

  capacity_type = each.value.capacity_type
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size = each.value.scaling_config.max_size
    min_size = each.value.scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = each.key
  }

  depends_on = [ aws_iam_role_policy_attachment.nodes ]
}
