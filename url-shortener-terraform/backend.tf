terraform {
  backend "s3" {
    bucket = "jaz-sandbox-tfstate"
    key    = "urlshortener.tfstate"
    region = "ap-southeast-1"
  }
}