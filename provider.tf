variable "aws_profile_name" {}
variable "aws_region" {}

provider "aws" {
  profile = "${var.aws_profile_name}"
  region  = "${var.aws_region}"
}
