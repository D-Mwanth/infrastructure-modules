variable "env" {
    description = "Enviroment name."
    type = string
}

variable "vpc_cidr_block" {
    description = "Classless Inter-Domain Rounting (CIDR)."
    type = string
    default = "10.0.0.0/16"
}

variable "azs" {
    description = "Availability zones for subnets"
    type = list(string)
}

variable "private_subnets" {
    description = "CIDR ranges for private subnets."
    type = list(string)
}

variable "public_subnets" {
    description = "CIDR ranges for private subnets."
    type = list(string)
}

variable "private_subnets_tags" {
    description = "Private subnet tags."
    type = map(any)
}

variable "public_subnets_tags" {
  description = "Private subnet tags."
  type        = map(any)
}

