
# Check if we can get access to our New Relic account
variable "NEWRELIC_ACCOUNT_ID" {}
data "newrelic_account" "data_check_newrelic" {
  scope = "global"
  account_id = var.NEWRELIC_ACCOUNT_ID
}

# Check if we have access to our AWS account
data "aws_ec2_instance_type" "data_check_aws" {
  instance_type = "t2.micro"
}

