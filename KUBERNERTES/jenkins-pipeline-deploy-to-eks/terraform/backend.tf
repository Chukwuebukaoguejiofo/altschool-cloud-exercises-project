terraform {
  backend "s3" {
    bucket = "ebuka101-terraform-app"
    region = "us-east-1"
    key = "eks/terraform.tfstate"
  }
}