variable "vpc_cidr" {  default = "10.1.0.0/16" }
variable "front_subnet_cidr" { 
	type = "list"
	default = ["10.1.0.0/24","10.1.1.0/24"]
}
variable "app_subnet_cidr" { 
	type = "list"
	default = ["10.1.2.0/24","10.1.3.0/24"]
}
variable "zones" {
	type = "list"
	default = ["us-east-1a","us-east-1b"]
}
