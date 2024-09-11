variable "env" {
  description = "Environment name."
  type        = string
}

variable "eks_name" {
  description = "Name of the cluster."
  type        = string
}
variable "vpc_id" {
  description = "ID of the vpc cluster is deployed in"
  type        = string
}
