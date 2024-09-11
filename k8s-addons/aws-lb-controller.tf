# Create IAM role for the AWS LB controller
resource "aws_iam_role" "this" {
  name               = "${var.eks_name}-aws-lbc"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

# Create necessary policies
resource "aws_iam_policy" "this" {
  policy = file("./iam/aws-lb-controller-policy.json")
  name   = "${var.eks_name}-aws-lbc"
}

# Attach the policies to the IAM role
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# Associate the pod identity with IAM role
resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.eks_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.this.arn
}

# Controller release helm chart
resource "helm_release" "this" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = var.eks_name
  }

  set {
    name  = "region"
    value = "eu-north-1"
  }

  set {
    name = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  
  depends_on = [helm_release.cluster_autoscaler]
}
