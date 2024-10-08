variable "env" {
  description = "Enviroment name."
  type = string
}

variable "eks_version" {
  description = "Desired Kubernetes master version"
  type = string
}

variable "eks_name" {
  description = "Name of the cluster"
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs. Must be in at least two different availability zones"
  type = list(string)
}

variable "node_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes"
  type = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "node_groups" {
  description = "EKS nade groups"
  type = map(any)
}
