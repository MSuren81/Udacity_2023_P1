variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default ="West Europe"
}

variable "username" {
  description = "The username that you want to use for this VM"
}

variable "password" {
  description = "please store the pw here or somewehre else"
}
variable "tags" {
    description = "Tags for the resources"
    default = {"udacityTag":"testTag"}
}
    
variable "environment" {
  description = "Tag for the environment"
  default = "Development"
} 
variable "project"{
  description = "tag of the project"
  default = "Udacity2023_P1"
}