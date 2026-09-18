variable "vpc_cidr_block" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "public_cidr_block" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}

variable "private_cidr_block" {
  type = list(string)
}

variable "db_cidr_block" {
  type = list(string)
}