terraform {
  backend "s3" {
    bucket = "sctp-core-tfstate"
    key    = "shortener-demo.tfstate"
    region = "ap-southeast-1"
  }
}