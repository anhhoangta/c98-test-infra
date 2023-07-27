terraform {
  backend "s3" {
    bucket = "c98-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
