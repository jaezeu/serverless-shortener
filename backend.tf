terraform {
  backend "s3" {
    bucket = "sctp-ce4-tfstate-bucket"
    key    = "jazeel-shortener.tfstate"
    region = "ap-southeast-1"
  }
}