terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key    = "shortener-demo.tfstate"
    region = "ap-southeast-1"
  }
}