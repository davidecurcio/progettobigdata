variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-0ac80df6eff0e70b5"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "private_key_name" {
  default = "key_bigdata"
}

variable "private_key_path" {
  default = "~/progetto_bigdata/connessione_terraform/key_bigdata.pem"
}