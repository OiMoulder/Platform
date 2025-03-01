terraform {
  backend "s3" {
    bucket = "oimoulder-terraform" 
    key    = "tfstate"
    region = "eu-west-2"
  }
}