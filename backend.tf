terraform {
  backend "s3" {
    bucket = "terraform-c98-test"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
