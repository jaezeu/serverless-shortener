terraform {
  backend "s3" {
    bucket = "sctp-ce6-tfstate"
    key    = "jazeel-shortener.tfstate"
    region = "ap-southeast-1"
  }
}