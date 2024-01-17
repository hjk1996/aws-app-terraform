variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "app-vpc"
}

variable "subnet_list" {
  type = map(string)
  default = {
    "1" = "a"
    "2" = "b"
    "3" = "c"
  }
}

